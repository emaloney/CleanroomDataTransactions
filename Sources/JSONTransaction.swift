//
//  JSONTransaction.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 7/28/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation
import CleanroomConcurrency

public class JSONTransaction<JSONDataType>: WrappingDataTransaction
{
    public typealias DataType = JSONDataType
    public typealias MetadataType = WrappedTransactionType.MetadataType
    public typealias Result = TransactionResult<DataType, MetadataType>
    public typealias Callback = (Result) -> Void
    public typealias WrappedTransactionType = URLTransaction
    public typealias JSONPayloadProcessor = (AnyObject?) throws -> DataType
    public typealias MetadataProcessor = (MetadataType?, payload: DataType) throws -> Void

    private let wrappedTransaction: WrappedTransactionType

    public var url: NSURL { return wrappedTransaction.url }

    public var jsonReadingOptions = NSJSONReadingOptions(rawValue: 0)
    public var payloadProcessingFunction: JSONPayloadProcessor = requiredPayloadProcessor
    public var metadataProcessingFunction: MetadataProcessor?

    public init(url: NSURL, uploadData: NSData? = nil)
    {
        wrappedTransaction = WrappedTransactionType(url: url, uploadData: uploadData)
    }

    public init(request: NSURLRequest, uploadData: NSData? = nil)
    {
        wrappedTransaction = WrappedTransactionType(request: request, uploadData: uploadData)
    }

    public init(wrapping: WrappedTransactionType)
    {
        wrappedTransaction = wrapping
    }

    public func executeTransaction(completion: Callback)
    {
        wrappedTransaction.executeTransaction() { result in
            switch result {
            case .Failed(let error):
                completion(.Failed(error))

            case .Succeeded(let data, let meta):
                async {
                    do {
                        let json: AnyObject?
                        if data.length > 0 {
                            json = try NSJSONSerialization.JSONObjectWithData(data, options: self.jsonReadingOptions)
                        } else {
                            json = nil
                        }

                        let payload = try self.payloadProcessingFunction(json)

                        if let metadataProcessor = self.metadataProcessingFunction {
                            try metadataProcessor(meta, payload: payload)
                        }

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

public typealias JSONDictionaryTransaction = JSONTransaction<NSDictionary>

public typealias JSONArrayTransaction = JSONTransaction<NSArray>

public class JSONOptionalTransaction<T>: JSONTransaction<T?>
{
    public override init(request: NSURLRequest, uploadData: NSData? = nil)
    {
        super.init(request: request, uploadData: uploadData)

        payloadProcessingFunction = optionalPayloadProcessor
    }

    public override init(url: NSURL, uploadData: NSData? = nil)
    {
        super.init(url: url, uploadData: uploadData)

        payloadProcessingFunction = optionalPayloadProcessor
    }
}

public typealias JSONOptionalDictionaryTransaction = JSONOptionalTransaction<NSDictionary>

public typealias JSONOptionalArrayTransaction = JSONOptionalTransaction<NSArray>
