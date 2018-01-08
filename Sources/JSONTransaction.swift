//
//  JSONTransaction.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 7/28/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 Connects to a network service to retrieve a JSON document of the generic type
 `JSONIntermediateType`. The `JSONPayloadProcessor` then attempts to convert
 the JSON intermediate type into the final `ResponseDataType`.
 */
open class JSONTransaction<JSONIntermediateType, ResponseDataType>: HTTPTransaction<ResponseDataType>
{
    /** The signature of a function to remove envelope wrapping from the JSON
     structure returned by the server. Certain JSON-based services embed the
     `JSONIntermediateType` payload inside envelope metadata about the 
     transaction. In such cases, it is necessary to remove the envelope and
     return a `JSONIntermediateType` without it so the `JSONPayloadProcessor`
     can properly parse the JSON into the `ResponseDataType`. */
    public typealias JSONEnvelopeUnwrapper = (JSONTransaction<JSONIntermediateType, ResponseDataType>, JSONIntermediateType) throws -> JSONIntermediateType

    /** The signature of a JSON payload processing function. This function
     accepts a JSON object (of type `JSONIntermediateType`) and attempts to 
     convert it to `HTTPDataType`. */
    public typealias JSONPayloadProcessor = (JSONTransaction<JSONIntermediateType, ResponseDataType>, JSONIntermediateType) throws -> ResponseDataType

    /** The `JSONEnvelopeUnwrapper` that will be used to remove the JSON
     payload from any JSON envelope it may be wrapped in. The default 
     implementation assumes there is no envelope, and simply returns
     the passed-in JSON object. */
    public var unwrapJSON: JSONEnvelopeUnwrapper = { _, jsonObject in
        // in many cases, there isn't an envelope to unwrap; this default
        // implementation just returns the incoming JSON, doing nothing.
        return jsonObject
    }

    /** The `JSONPayloadProcessor` that will be used to convert a JSON
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

     - parameter method: The HTTP request method. When not explicitly set,
     defaults to `.get` unless `data` is non-`nil`, in which case the value
     defaults to `.post`.

     - parameter data: Optional binary data to send to the network
     service.
     
     - parameter contentType: The MIME type of `data`. If present, this value
     is sent as the `Content-Type` header for the HTTP request.

     - parameter queue: A `DispatchQueue` to use for processing transaction
     responses.
     */
    public init(url: URL, method: HTTPRequestMethod? = nil, upload data: Data? = nil, contentType: MIMEType? = nil, processingQueue queue: DispatchQueue = .transactionProcessing)
    {
        var mime = contentType
        if mime == nil && data != nil {
            mime = .json
        }

        super.init(url: url, method: method, upload: data, contentType: mime, transactionType: .api, processingQueue: queue)

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
    open func extractPayloadFromData(transaction: HTTPTransaction<ResponseDataType>, content: Data, meta: HTTPResponseMetadata)
        throws
        -> ResponseDataType
    {
        // always used the passed-in transaction instead of self;
        // this way we're insulated against someone swapping the
        // function implementation instances
        guard let txn = transaction as? JSONTransaction<JSONIntermediateType, ResponseDataType> else {
            throw DataTransactionError.incompatibleType
        }

        guard let rawJSON = try txn.jsonObject(from: content) as? JSONIntermediateType else {
            throw DataTransactionError.incompatibleType
        }

        // many endpoints wrap up payload in JSON metadata structures;
        // this hook enables unwrapping it
        let strippedJSON = try txn.unwrapJSON(txn, rawJSON)

        return try txn.processJSON(txn, strippedJSON)
    }

    /**
     Attempts to convert the content of an HTTP response into a JSON object.

     This implementation calls `JSONSerialization.jsonObject()` with no
     options. Subclasses may override to provide different behavior.

     - parameter content: The content (body) of the HTTP response.

     - returns: The JSON object, or `nil` if `content` contains a `0` byte
     count.

     - throws: If `content` could not be interpreted into a JSON object.
     */
    open func jsonObject(from content: Data)
        throws
        -> Any
    {
        guard !content.isEmpty else {
            return ()
        }

        return try JSONSerialization.jsonObject(with: content, options: [])
    }

    /**
     Attempts to interpret a JSON object as an instance of `ResponseDataType`.

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
    open func extractPayloadFromParsedJSON(_ jsonObject: JSONIntermediateType)
        throws
        -> ResponseDataType
    {
        guard let payload = jsonObject as? ResponseDataType else {
            throw DataTransactionError.jsonFormatError("Expecting JSON data to be a type of \(ResponseDataType.self); got \(type(of: jsonObject)) instead", jsonObject)
        }

        return payload
    }
}

/**
 A concrete `JSONTransaction` that attempts to generate a `JSONDictionary`
 from JSON data returned by the server.
 */
public typealias JSONDictionaryTransaction = JSONTransaction<JSONDictionary, JSONDictionary>

/**
 A concrete `JSONTransaction` that attempts to generate a `JSONArray`
 from JSON data returned by the server.
 */
public typealias JSONArrayTransaction = JSONTransaction<JSONArray, JSONArray>

/**
 A concrete `JSONOptionalTransaction` that accepts an optional JSON
 payload that—if present—is expected to yield a `JSONDictionary`.
 */
public typealias JSONOptionalDictionaryTransaction = JSONTransaction<JSONDictionary?, JSONDictionary?>

/**
 A concrete `JSONOptionalTransaction` that accepts an optional JSON
 payload that—if present—is expected to yield a `JSONArray`.
 */
public typealias JSONOptionalArrayTransaction = JSONTransaction<JSONArray?, JSONArray?>
