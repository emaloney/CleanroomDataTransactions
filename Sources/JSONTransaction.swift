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
     
     - parameter scheme: The protocol scheme used to communicate with
     the service.

     - parameter host: The hostname of the service.

     - parameter urlPath: The path portion of the URL at which the network
    /** An optional `PayloadValidationFunction` function used to interpret the 
     transaction metadata returned by the wrapped transaction. This is called 
     if and only if only if `processPayload()` did not throw an exception.*/
    public var validatePayload: PayloadValidationFunction?
     service is hosted.

     - parameter data: Optional binary data to send to the network
     service.
     */
    public init(scheme: String = NSURLProtectionSpaceHTTPS, host: String, urlPath: String, upload data: Data? = nil)
    {
        super.init(scheme: scheme, host: host, urlPath: urlPath, transactionType: .api, upload: data)

        self.processPayload = { _, data, _ in
            let json = try JSONSerialization.jsonObject(with: data, options: [])

            guard let payload = json as? T else {
                throw DataTransactionError.jsonFormatError("Expecting JSON data to be a type of \(T.self); got \(type(of: json)) instead", data)
            }

            return payload
        }
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
