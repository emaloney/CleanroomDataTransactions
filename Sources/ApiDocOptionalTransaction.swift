//
//  ApiDocOptionalTransaction.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 7/28/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 A generic `JSONTransaction` implementation that accepts an optional payload 
 from an [apidoc.me](http://apidoc.me/)-style RESTful JSON network service.

 If the wrapped transaction returns data, the transaction tries to parse it
 as JSON data yielding the generic type `T`.

 If no payload if received, the transaction succeeds with a `nil` payload.

 If a JSON payload is received that results in an instance of the generic
 type `T`, the transaction succeeds with that payload.

 If a payload is received, but it could not be interpreted as an instance
 of the generic type `T`, the transaction fails.
 */
open class ApiDocOptionalTransaction<T>: JSONOptionalTransaction<T>
{
    /**
     Initializes an `ApiDocOptionalTransaction` to connect to the network 
     service at the given URL.

     - parameter url: The URL of the network service.

     - parameter data: Optional binary data to send to the network
     service.

     - parameter sessionConfiguration: A `URLSessionConfiguration` that will
     be used for the `URLSession` that governs the transaction's network
     request.
     
     - parameter processingQueue: A `DispatchQueue` to use for processing the
     response from the server.
     */
    public override init(url: URL, upload data: Data? = nil, sessionConfiguration: URLSessionConfiguration = .default, processingQueue: DispatchQueue = .transactionProcessing)
    {
        super.init(url: url, upload: data, sessionConfiguration: sessionConfiguration, processingQueue: processingQueue)

        validateMetadata = httpRequiredStatusCodeValidator
        processPayload = optionalPayloadProcessor
    }

    /**
     Initializes an `ApiDocOptionalTransaction` to issue the specified request 
     to the network service.

     - parameter request: The `URLRequest` to issue to the network service.

     - parameter data: Optional binary data to send to the network
     service.

     - parameter sessionConfiguration: A `URLSessionConfiguration` that will
     be used for the `URLSession` that governs the transaction's network
     request.
     
     - parameter processingQueue: A `DispatchQueue` to use for processing the
     response from the server.
     */
    public override init(request: URLRequest, upload data: Data? = nil, sessionConfiguration: URLSessionConfiguration = .default, processingQueue: DispatchQueue = .transactionProcessing)
    {
        super.init(request: request, upload: data, sessionConfiguration: sessionConfiguration, processingQueue: processingQueue)

        validateMetadata = httpRequiredStatusCodeValidator
        processPayload = optionalPayloadProcessor
    }

    /**
     Initializes an `ApiDocOptionalTransaction` that wraps the specified 
     transaction.

     - parameter wrapping: The `DataTransaction` to wrap within the
     `JSONTransaction` instance being initialized.

     - parameter processingQueue: A `DispatchQueue` to use for processing the
     response from the server.
     */
    public override init(wrapping: WrappedTransactionType, processingQueue: DispatchQueue = .transactionProcessing)
    {
        super.init(wrapping: wrapping, processingQueue: processingQueue)

        validateMetadata = httpRequiredStatusCodeValidator
        processPayload = optionalPayloadProcessor
    }
}

/**
 A concrete `ApiDocOptionalTransaction` type that accepts an optional JSON
 payload that—if present—is expected to yield a `[String: Any]`.
 */
public typealias ApiDocOptionalDictionaryTransaction = ApiDocOptionalTransaction<[String: Any]>

/**
 A concrete `ApiDocOptionalTransaction` type that accepts an optional JSON
 payload that—if present—is expected to yield a `[Any]`.
 */
public typealias ApiDocOptionalArrayTransaction = ApiDocOptionalTransaction<[Any]>
