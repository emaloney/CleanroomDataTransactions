//
//  GenericPayloadTransaction.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 1/28/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 An `HTTPTransaction` that provides a mechanism to extract a payload of type
 `T`.
 */
open class GenericPayloadTransaction<T>: HTTPTransaction
{
    public typealias PayloadType = T

    /** The result type passed to the transaction completion callback
     function. */
    public typealias Result = TransactionResult<PayloadType, HTTPResponseMetadata>

    /** The signature of the callback function passed to
     `executeTransaction()`. */
    public typealias Callback = (Result) -> Void

    /** The signature of a payload processing function. This function accepts
     binary `Data` and attempts to convert it to `DataType`. */
    public typealias PayloadProcessor = (GenericPayloadTransaction<PayloadType>, Data, HTTPResponseMetadata) throws -> PayloadType

    /** If the payload processor succeeds, the results are passed to the
     payload validator, giving the transaction one final chance to sanity-check
     the data and bail if there's a problem. */
    public typealias PayloadValidator = (GenericPayloadTransaction<PayloadType>, PayloadType, Data, HTTPResponseMetadata) throws -> Void

    /**  The `PayloadProcessor` that will be used to produce the receiver's 
     `DataType` upon successful completion of the transaction. */
    public let processPayload: PayloadProcessor

    /**  The `PayloadValidator` that will be used to validate the `DataType`
     produced by the `PayloadProcessor` upon successful completion of the
     transaction. */
    public var validatePayload: PayloadValidator = { _, _, _, _ in }

    private let processingQueue: DispatchQueue

    /**
     Initializes a new `GenericPayloadTransaction`.
     
     - parameter scheme: The protocol scheme used to communicate with
     the service.

     - parameter host: The hostname of the service.

     - parameter urlPath: The path portion of the URL at which the network
     service is hosted. If non-empty, this string _must_ begin with a slash
     ("`/`") character.

     - parameter transactionType: Specifies the transaction type.

     - parameter data: Optional data to send to the network service.

     - parameter processingQueue: The `DispatchQueue` to use for processing
     the payload.

     - parameter processPayload: The `PayloadProcessor` function that will be
     used to produce the `PayloadType` from a binary `Data` instance.
     */
    public init(scheme: String = NSURLProtectionSpaceHTTPS, host: String, urlPath: String, transactionType: TransactionType = .api, upload data: Data? = nil, processingQueue: DispatchQueue = .transactionProcessing, processPayload: @escaping PayloadProcessor)
    {
        self.processPayload = processPayload
        self.processingQueue = processingQueue

        super.init(scheme: scheme, host: host, urlPath: urlPath, transactionType: transactionType, upload: data)
    }

    /**
     Causes the transaction to be executed. The transaction may be performed
     asynchronously. When complete, the `Result` is reported to the `Callback`
     function.

     - parameter completion: A function that will be called upon completion
     of the transaction.
     */
    open func executeTransaction(completion: @escaping Callback)
    {
        super.executeTransaction() { [weak self] result in
            switch result {
            case .succeeded(let data, let meta):
                guard let `self` = self else {
                    completion(.failed(.canceled))
                    return
                }

                self.processingQueue.async {
                    do {
                        let payload = try self.processPayload(self, data, meta)
                        try self.validatePayload(self, payload, data, meta)
                        completion(Result.succeeded(payload, meta))
                    }
                    catch {
                        completion(.failed(.wrap(error)))
                    }
                }

            case .failed(let error):
                completion(.failed(error))
            }
        }
    }
}
