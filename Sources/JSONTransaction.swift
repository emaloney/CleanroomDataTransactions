//
//  JSONTransaction.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 7/28/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 Connects to a network service to retrieve a JSON document.
 
 Because the root object of a JSON document may be one of several types,
 a successful `JSONTransaction` produces the generic type `T` (also known
 herein as `DataType` via conformance to the `DataTransaction` protocol).
 */
open class JSONTransaction<T>: HTTPTransaction<T>
{
    /** The signature of a JSON payload processing function. This function
     accepts a JSON object (of type `Any`) and attempts to convert it to 
     `DataType`. */
    public typealias JSONPayloadProcessor = (JSONTransaction<T>, Any) throws -> DataType

    /**  The `JSONPayloadProcessor` that will be used to convert a JSON
     object (of type `Any`) to the `DataType` of the transaction. The default
     implementation calls `extractPayloadFromParsedJSON()`, which simply
     performs a typecast. If that is insufficient, you may either replace
     the function stored in `processJSON` or subclass to provide an alternate
     implementation of `extractPayloadFromParsedJSON()`. */
    public var processJSON: JSONPayloadProcessor = { txn, jsonObject in
        return try txn.extractPayloadFromParsedJSON(jsonObject)
    }

    /**
     Initializes a `JSONTransaction` to connect to the network service at the
     given URL.
     
     - parameter url: The URL to use for conducting the transaction.

     - parameter data: Optional binary data to send to the network
     service.
     */
    public init(url: URL, upload data: Data? = nil)
    {
        super.init(url: url, transactionType: .api, upload: data)

        self.processPayload = extractPayloadFromData
    }

    /**
     The payload processing function used by default for `JSONTransaction`
     instances.

     This function extracts a JSON object from binary `Data` using the
     `jsonObject(from:)` function and—if successful—attempts to convert the
     result to type `DataType` using the `JSONPayloadProcessor`.
     
     - parameter transaction: The transaction for which the function is
     executing. Under normal circumstances, this is the same as `self`.
     
     - parameter content: The content (body) of the HTTP response.
     
     - parameter meta: The response metadata.
     
     - returns: The payload, an instance of `DataType`.
     
     - throws: If `content` could not be interpreted into a JSON object, or if
     that JSON object could not be interpreted as an instance of type 
     `DataType`.
     */
    open func extractPayloadFromData(transaction: HTTPTransaction<T>, content: Data, meta: HTTPResponseMetadata)
        throws
        -> DataType
    {
        // always used the passed-in transaction instead of self;
        // this way we're insulated against someone swapping the
        // function implementation instances
        guard let txn = transaction as? JSONTransaction<DataType> else {
            throw DataTransactionError.incompatibleType
        }

        let json = try txn.jsonObject(from: content)

        return try txn.processJSON(txn, json)
    }

    /**
     Attempts to convert the content of an HTTP response into a JSON object.

     This implementation calls `JSONSerialization.jsonObject()` with no
     options. Subclasses may override to provide different behavior.

     - parameter content: The content (body) of the HTTP response.

     - returns: The JSON object.

     - throws: If `content` could not be interpreted into a JSON object.
     */
    open func jsonObject(from content: Data)
        throws
        -> Any
    {
        return try JSONSerialization.jsonObject(with: content, options: [])
    }

    /**
     Attempts to interpret a JSON object as an object of type `DataType`.

     The default implementation simply attempts to cast `jsonObject` as type
     `DataType`. This is sufficient if you're expecting a `JSONDictionary`
     or a `JSONArray`. In other cases, subclassing or replacing the
     `JSONPayloadProcessor` function in the `processJSON` property is
     necessary.

     - parameter jsonObject: The JSON object.

     - returns: An instance `DataType`, representing the value extracted from
     the `jsonObject`.

     - throws: If `jsonObject` could not be interpreted as an instance of
     type `DataType`.
     */
    open func extractPayloadFromParsedJSON(_ jsonObject: Any)
        throws
        -> DataType
    {
        guard let payload = jsonObject as? DataType else {
            throw DataTransactionError.jsonFormatError("Expecting JSON data to be a type of \(DataType.self); got \(type(of: jsonObject)) instead", jsonObject)
        }

        return payload
    }
}

/**
 A concrete `JSONTransaction` that attempts to generate a `JSONDictionary`
 from JSON data returned by the server.
 */
public typealias JSONDictionaryTransaction = JSONTransaction<JSONDictionary>

/**
 A concrete `JSONTransaction` that attempts to generate a `JSONArray`
 from JSON data returned by the server.
 */
public typealias JSONArrayTransaction = JSONTransaction<JSONArray>

/**
 A concrete `JSONOptionalTransaction` that accepts an optional JSON
 payload that—if present—is expected to yield a `JSONDictionary`.
 */
public typealias JSONOptionalDictionaryTransaction = JSONTransaction<JSONDictionary?>

/**
 A concrete `JSONOptionalTransaction` that accepts an optional JSON
 payload that—if present—is expected to yield a `JSONArray`.
 */
public typealias JSONOptionalArrayTransaction = JSONTransaction<JSONArray?>
