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
 a successful `JSONTransaction` produces the generic type `T`.
 */
open class JSONTransaction<T>: HTTPTransaction<T>
{
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

        self.processPayload = extractPayloadFromJSON
    }

    open func extractPayloadFromJSON(transaction: HTTPTransaction<T>, data: Data, meta: HTTPResponseMetadata)
        throws
        -> T
    {
        let json = try jsonObject(from: data)

        return try processJSON(json, from: data)
    }

    open func jsonObject(from data: Data)
        throws
        -> Any
    {
        return try JSONSerialization.jsonObject(with: data, options: [])
    }

    open func processJSON(_ jsonObject: Any, from data: Data)
        throws
        -> T
    {
        // this implementation is a simple cast; many implementations
        // will require more specialized parsing. in such cases, this
        // should be overridden in a subclass
        guard let payload = jsonObject as? T else {
            throw DataTransactionError.jsonFormatError("Expecting JSON data to be a type of \(T.self); got \(type(of: jsonObject)) instead", data)
        }

        return payload
    }
}

/**
 A concrete `JSONTransaction` type that attempts to generate a `JSONDictionary`
 from JSON data returned by the wrapped transaction.
 */
public typealias JSONDictionaryTransaction = JSONTransaction<JSONDictionary>

/**
 A concrete `JSONTransaction` type that attempts to generate a `JSONArray`
 from JSON data returned by the wrapped transaction.
 */
public typealias JSONArrayTransaction = JSONTransaction<JSONArray>

/**
 A concrete `JSONOptionalTransaction` type that accepts an optional JSON
 payload that—if present—is expected to yield a `JSONDictionary`.
 */
public typealias JSONOptionalDictionaryTransaction = JSONTransaction<JSONDictionary?>

/**
 A concrete `JSONOptionalTransaction` type that accepts an optional JSON
 payload that—if present—is expected to yield a `JSONArray`.
 */
public typealias JSONOptionalArrayTransaction = JSONTransaction<JSONArray?>
