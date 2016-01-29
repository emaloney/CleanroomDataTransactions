//
//  JSONTransaction.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 7/28/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation
import CleanroomConcurrency

/**
 Uses a wrapped `URLTransaction` to connect to a network service to retrieve
 a JSON document.
 
 Because the root object of a JSON document may be one of several types,
 a successful `JSONTransaction` produces the generic `JSONDataType`. The
 `JSONPayloadProcessor` function is used to produce the expected type.
 */
public class JSONTransaction<JSONDataType>: WrappingDataTransaction
{
    public typealias DataType = JSONDataType
    public typealias MetadataType = WrappedTransactionType.MetadataType
    public typealias Result = TransactionResult<DataType, MetadataType>
    public typealias Callback = (Result) -> Void
    public typealias WrappedTransactionType = URLTransaction

    /** The signature of the JSON payload processing function. */
    public typealias JSONPayloadProcessor = (AnyObject?) throws -> DataType

    /** The signature of the transaction metadata processing function. */
    public typealias MetadataProcessor = (MetadataType?, payload: DataType) throws -> Void

    /** The URL of the wrapped `DataTransaction`. */
    public var url: NSURL { return wrappedTransaction.url }

    /** The options to use when reading JSON. */
    public var jsonReadingOptions = NSJSONReadingOptions(rawValue: 0)

    /** A `JSONPayloadProcessor` function used to convert the JSON data into an
     object of the generic type `JSONDataType`. */
    public var payloadProcessingFunction: JSONPayloadProcessor = requiredPayloadProcessor

    /** A `MetadataProcessor` function used to interpret the transaction
     metadata returned by the wrapped transaction. */
    public var metadataProcessingFunction: MetadataProcessor?

    private let wrappedTransaction: WrappedTransactionType

    /**
     Initializes a `JSONTransaction` to connect to the network service at the
     given URL.
     
     - parameter url: The URL of the network service.
     
     - parameter uploadData: Optional binary data to send to the network
     service.
     */
    public init(url: NSURL, uploadData: NSData? = nil)
    {
        wrappedTransaction = WrappedTransactionType(url: url, uploadData: uploadData)
    }

    /**
     Initializes a `JSONTransaction` to issue the specified request to the
     network service.

     - parameter request: The `NSURLRequest` to issue to the network service.

     - parameter uploadData: Optional binary data to send to the network
     service.
     */
    public init(request: NSURLRequest, uploadData: NSData? = nil)
    {
        wrappedTransaction = WrappedTransactionType(request: request, uploadData: uploadData)
    }

    /**
     Initializes a `JSONTransaction` that wraps the specified transaction.

     - parameter wrapping: The `DataTransaction` to wrap within the
     `JSONTransaction` instance being initialized.
     */
    public init(wrapping: WrappedTransactionType)
    {
        wrappedTransaction = wrapping
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

/**
 A generic `JSONTransaction` implementation that accepts an optional payload.
 
 If the wrapped transaction returns data, the transaction tries to parse it
 as JSON data yielding the generic type `T`.

 If no payload if received, the transaction succeeds with a `nil` payload.
 
 If a JSON payload is received that results in an instance of the generic
 type `T`, the transaction succeeds with that payload.
 
 If a payload is received, but it could not be interpreted as an instance
 of the generic type `T`, the transaction fails.
 */
public class JSONOptionalTransaction<T>: JSONTransaction<T?>
{
    /**
     Initializes a `JSONOptionalTransaction` to connect to the network service
     at the given URL.

     - parameter url: The URL of the network service.

     - parameter uploadData: Optional binary data to send to the network
     service.
     */
    public override init(url: NSURL, uploadData: NSData? = nil)
    {
        super.init(url: url, uploadData: uploadData)

        payloadProcessingFunction = optionalPayloadProcessor
    }

    /**
     Initializes a `JSONOptionalTransaction` that wraps the specified 
     transaction.

     - parameter request: The `NSURLRequest` to issue to the network service.

     - parameter uploadData: Optional binary data to send to the network
     service.
     */
    public override init(request: NSURLRequest, uploadData: NSData? = nil)
    {
        super.init(request: request, uploadData: uploadData)

        payloadProcessingFunction = optionalPayloadProcessor
    }

    /**
     Initializes a `JSONOptionalTransaction` that wraps the specified
     transaction.

     - parameter wrapping: The `DataTransaction` to wrap within the
     `JSONOptionalTransaction` instance being initialized.
     */
    public override init(wrapping: WrappedTransactionType)
    {
        super.init(wrapping: wrapping)

        payloadProcessingFunction = optionalPayloadProcessor
    }
}

/**
 A concrete `JSONOptionalTransaction` type that accepts an optional JSON 
 payload that—if present—is expected to yield an `NSDictionary`.
 */
public typealias JSONOptionalDictionaryTransaction = JSONOptionalTransaction<NSDictionary>

/**
 A concrete `JSONOptionalTransaction` type that accepts an optional JSON
 payload that—if present—is expected to yield an `NSArray`.
 */
public typealias JSONOptionalArrayTransaction = JSONOptionalTransaction<NSArray>
