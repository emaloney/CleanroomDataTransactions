//
//  ApiDocTransaction.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 7/28/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 Uses a wrapped `URLTransaction` to connect to an 
 [apidoc.me](http://apidoc.me/)-style RESTful JSON network service.

 Because the root object of a JSON document may be one of several types,
 a successful `ApiDocTransaction` produces the generic `JSONDataType`. The
 `PayloadProcessingFunction` function is used to produce the expected type.
 */
public class ApiDocTransaction<T>: JSONTransaction<T>
{
    /**
     Initializes an `ApiDocTransaction` to connect to the network service at
     the given URL.

     - parameter url: The URL of the network service.

     - parameter uploadData: Optional binary data to send to the network
     service.
     */
    public override init(url: NSURL, uploadData: NSData? = nil)
    {
        super.init(url: url, uploadData: uploadData)

        validateMetadata = httpRequiredStatusCodeValidator
    }

    /**
     Initializes an `ApiDocTransaction` to issue the specified request to the
     network service.

     - parameter request: The `NSURLRequest` to issue to the network service.

     - parameter uploadData: Optional binary data to send to the network
     service.
     */
    public override init(request: NSURLRequest, uploadData: NSData? = nil)
    {
        super.init(request: request, uploadData: uploadData)

        validateMetadata = httpRequiredStatusCodeValidator
    }

    /**
     Initializes an `ApiDocTransaction` that wraps the specified transaction.

     - parameter wrapping: The `DataTransaction` to wrap within the
     `JSONTransaction` instance being initialized.
     */
    public override init(wrapping: WrappedTransactionType)
    {
        super.init(wrapping: wrapping)

        validateMetadata = httpRequiredStatusCodeValidator
    }
}

/**
 A concrete `ApiDocTransaction` type that attempts to generate an `NSDictionary`
 from JSON data returned by the wrapped transaction.
 */
public typealias ApiDocDictionaryTransaction = ApiDocTransaction<NSDictionary>

/**
 A concrete `ApiDocTransaction` type that attempts to generate an `NSArray`
 from JSON data returned by the wrapped transaction.
 */
public typealias ApiDocArrayTransaction = ApiDocTransaction<NSArray>
