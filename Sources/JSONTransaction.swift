//
//  JSONTransaction.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 7/28/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 Uses a wrapped `URLTransaction` to connect to a network service to retrieve
 a JSON document.
 
 Because the root object of a JSON document may be one of several types,
 a successful `JSONTransaction` produces the generic type `T`. The
 `PayloadProcessingFunction` function is used to produce the expected type.
 */
public class JSONTransaction<T>: WrappingDataTransaction
{
    public typealias DataType = T
    public typealias MetadataType = WrappedTransactionType.MetadataType
    public typealias Result = TransactionResult<DataType, MetadataType>
    public typealias Callback = (Result) -> Void
    public typealias WrappedTransactionType = URLTransaction

    /** The signature of the transaction metadata validation function. This
     function throws an exception if validation fails, causing the transaction
     itself to fail. */
    public typealias MetadataValidationFunction = (MetadataType, data: NSData?) throws -> Void

    /** The signature of the JSON payload processing function. This function 
     attempts to convert the JSON data into the transaction payload of the
     type specified by receiver's `DataType`. The function throws an exception
     if payload processing fails, causing the transaction itself to fail. */
    public typealias PayloadProcessingFunction = (AnyObject?) throws -> DataType

    /** If the payload processor succeeds, the resulting `DataType` and the
     transaction's metadata are passed to the payload validator, giving the
     transaction one final change to sanity-check the data and bail if there's
     a problem. The function throws an exception if payload validation fails,
     causing the transaction itself to fail. */
    public typealias PayloadValidationFunction = (DataType, metadata: MetadataType) throws -> Void

    /** The URL of the wrapped `DataTransaction`. */
    public var url: NSURL { return _wrappedTransaction.url }

    /** The options to use when reading JSON. */
    public var jsonReadingOptions = NSJSONReadingOptions(rawValue: 0)

    /** An optional `MetadataValidationFunction` function that will be called 
     before attempting to process the transaction's payload. This function is 
     given the first chance to abort the transaction if there's a problem. */
    public var validateMetadata: MetadataValidationFunction?

    /** A `PayloadProcessingFunction` function used to convert the JSON data
     into an object of the generic type `T`. This is called if and only if
     `validateMetadata()` did not throw an exception. */
    public var processPayload: PayloadProcessingFunction = requiredPayloadProcessor

    /** An optional `PayloadValidationFunction` function used to interpret the 
     transaction metadata returned by the wrapped transaction. This is called 
     if and only if only if `processPayload()` did not throw an exception.*/
    public var validatePayload: PayloadValidationFunction?

    /** The underlying transaction used by a `WrappingDataTransaction` for
     lower-level processing. */
    public var wrappedTransaction: WrappedTransactionType? {
        return _wrappedTransaction
    }
    private let _wrappedTransaction: WrappedTransactionType

    private let queueProvider: QueueProvider

    /**
     Initializes a `JSONTransaction` to connect to the network service at the
     given URL.
     
     - parameter url: The URL of the network service.
     
     - parameter uploadData: Optional binary data to send to the network
     service.
     
     - parameter queueProvider: Used to supply a GCD queue for asynchronous 
     operations when needed.
     */
    public init(url: NSURL, uploadData: NSData? = nil, queueProvider: QueueProvider = DefaultQueueProvider.instance)
    {
        self.queueProvider = queueProvider
        _wrappedTransaction = WrappedTransactionType(url: url, uploadData: uploadData)
    }

    /**
     Initializes a `JSONTransaction` to issue the specified request to the
     network service.

     - parameter request: The `NSURLRequest` to issue to the network service.

     - parameter uploadData: Optional binary data to send to the network
     service.

     - parameter queueProvider: Used to supply a GCD queue for asynchronous
     operations when needed.
     */
    public init(request: NSURLRequest, uploadData: NSData? = nil, queueProvider: QueueProvider = DefaultQueueProvider.instance)
    {
        self.queueProvider = queueProvider
        _wrappedTransaction = WrappedTransactionType(request: request, uploadData: uploadData)
    }

    /**
     Initializes a `JSONTransaction` that wraps the specified transaction.

     - parameter wrapping: The `DataTransaction` to wrap within the
     `JSONTransaction` instance being initialized.

     - parameter queueProvider: Used to supply a GCD queue for asynchronous
     operations when needed.
     */
    public init(wrapping: WrappedTransactionType, queueProvider: QueueProvider = DefaultQueueProvider.instance)
    {
        _wrappedTransaction = wrapping
        self.queueProvider = queueProvider
    }

    /**
     Causes the transaction to be executed. The transaction may be performed
     asynchronously. When complete, the `Result` is reported to the `Callback`
     function.

     - parameter completion: A function that will be called upon completion
     of the transaction.
     */
    public func executeTransaction(completion: Callback)
    {
        _wrappedTransaction.executeTransaction() { result in
            switch result {
            case .Failed(let error):
                completion(.Failed(error))

            case .Succeeded(let data, let meta):
                self.queueProvider.queue.async {
                    do {
                        
                        try self.validateMetadata?(meta, data: data)
                        
                        let json: AnyObject?
                        if data.length > 0 {
                            json = try NSJSONSerialization.JSONObjectWithData(data, options: self.jsonReadingOptions)
                        } else {
                            json = nil
                        }

                        let payload = try self.processPayload(json)

                        try self.validatePayload?(payload, metadata: meta)

                        completion(.Succeeded(payload, meta))
                    }
                    catch {
                        completion(.Failed(.wrap(error)))
                    }
                }
            }
        }
    }
}

/**
 A concrete `JSONTransaction` type that attempts to generate an `NSDictionary`
 from JSON data returned by the wrapped transaction.
 */
public typealias JSONDictionaryTransaction = JSONTransaction<NSDictionary>

/**
 A concrete `JSONTransaction` type that attempts to generate an `NSArray`
 from JSON data returned by the wrapped transaction.
 */
public typealias JSONArrayTransaction = JSONTransaction<NSArray>
