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
public class ApiDocOptionalTransaction<T>: JSONOptionalTransaction<T>
{
    /**
     Initializes an `ApiDocOptionalTransaction` to connect to the network 
     service at the given URL.

     - parameter url: The URL of the network service.

     - parameter uploadData: Optional binary data to send to the network
     service.
     */
    public override init(url: NSURL, uploadData: NSData? = nil)
    {
        super.init(url: url, uploadData: uploadData)

        validateMetadata = httpRequiredStatusCodeValidator
        processPayload = optionalPayloadProcessor
    }

    /**
     Initializes an `ApiDocOptionalTransaction` to issue the specified request 
     to the network service.

     - parameter request: The `NSURLRequest` to issue to the network service.

     - parameter uploadData: Optional binary data to send to the network
     service.
     */
    public override init(request: NSURLRequest, uploadData: NSData? = nil)
    {
        super.init(request: request, uploadData: uploadData)

        validateMetadata = httpRequiredStatusCodeValidator
        processPayload = optionalPayloadProcessor
    }

    /**
     Initializes an `ApiDocOptionalTransaction` that wraps the specified 
     transaction.

     - parameter wrapping: The `DataTransaction` to wrap within the
     `JSONTransaction` instance being initialized.
     */
    public override init(wrapping: WrappedTransactionType)
    {
        super.init(wrapping: wrapping)

        validateMetadata = httpRequiredStatusCodeValidator
        processPayload = optionalPayloadProcessor
    }
}

/**
 A concrete `ApiDocOptionalTransaction` type that accepts an optional JSON
 payload that—if present—is expected to yield an `NSDictionary`.
 */
public typealias ApiDocOptionalDictionaryTransaction = ApiDocOptionalTransaction<NSDictionary>

/**
 A concrete `ApiDocOptionalTransaction` type that accepts an optional JSON
 payload that—if present—is expected to yield an `NSArray`.
 */
public typealias ApiDocOptionalArrayTransaction = ApiDocOptionalTransaction<NSArray>
