//
//  JSONDecodableTransaction.swift
//  CleanroomDataTransactions
//
//  Created by Nikita Korchagin on 20/07/2018.
//  Copyright © 2018 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 Connects to a network service to retrieve a JSON document and attempts to convert
 the JSON payload into the final `ResponseDataType` by using JSONDecoder.
 */
open class JSONDecodableTransaction<ResponseDataType: Decodable>: HTTPTransaction<ResponseDataType>
{

    /** The signature of a JSON payload decoding function. This function
     accepts a payload (of type `Data`) and attempts to
     convert it to `ResponseDataType`. */
    public typealias JSONPayloadDecoder = (JSONDecodableTransaction<ResponseDataType>, Data) throws -> ResponseDataType

    /** The `JSONPayloadDecoder` that will be used to convert a JSON
     payload (of type `Data`) to the `ResponseDataType` of the transaction. The default
     implementation calls `decodeJSON()`, which simply use default JSONDecoder.
     If that is insufficient, you may either replace
     the function stored in `decodeJSON` or subclass to provide an alternate
     implementation of `decodePayloadFormJSONData()`. */
    public var decodeJSON: JSONPayloadDecoder = { txn, jsonData in
        return try txn.decodePayloadFormJSONData(jsonData)
    }

    /**
     Initializes a `JSONDecodableTransaction` to connect to the network service at the
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

        processPayload = { transaction, data, _ in
            guard let txn = transaction as? JSONDecodableTransaction<ResponseDataType> else {
                throw DataTransactionError.incompatibleType
            }

            return try txn.decodeJSON(txn, data)
        }
    }

    /**
     Attempts to decode JSON payload as an instance of `ResponseDataType`.

     The default implementation simply use JSONDecoder. If that is insufficient
     subclassing or replacing the `JSONPayloadDecoder` function in the `decodeJSON` property is
     necessary.

     - parameter jsonData: The JSON payload of type `Data`.

     - returns: An instance `ResponseDataType`, representing the value extracted from
     the `jsonData`.

     - throws: If `jsonData` could not be interpreted as an instance of
     type `ResponseDataType`.
     */
    open func decodePayloadFormJSONData(_ jsonData: Data)
        throws
        -> ResponseDataType
    {
        let jsonDecoder = JSONDecoder()
        return try jsonDecoder.decode(ResponseDataType.self, from: jsonData)
    }
}
