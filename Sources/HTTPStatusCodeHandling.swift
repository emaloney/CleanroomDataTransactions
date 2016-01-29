//
//  JSONPayloadProcessing.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 1/28/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 A `MetadataValidationFunction` that expects its `MetadataType` to be `nil`
 or an instance of `HTTPResponseMetadata`.
 
 - parameter meta: An optional `MetadataType`.
 
 - parameter data: An optional `NSData` instance containing the transaction's
 raw response body.

 - throws: `DataTransactionError.HTTPError` if `meta` is an instance of
 `HTTPResponseMetadata` that represents either a client or server error.
 */
public func httpOptionalStatusCodeValidator<MetadataType>(meta: MetadataType?, data: NSData?)
    throws
{
    try httpStatusCodeValidator(meta, data: data, httpRequired: false)
}

/**
 A `MetadataValidationFunction` that expects its `MetadataType` to be an
 instance of `HTTPResponseMetadata`.

 - parameter meta: An optional `MetadataType`.

 - parameter data: An optional `NSData` instance containing the transaction's
 raw response body.

 - throws: `DataTransactionError.HTTPRequired` if `meta` is not an instance
 of `HTTPResponseMetadata`.
 
 - throws: `DataTransactionError.HTTPError` if `meta` is an instance of
 `HTTPResponseMetadata` that represents either a client or server error.
 */
public func httpRequiredStatusCodeValidator<MetadataType>(meta: MetadataType?, data: NSData?)
    throws
{
    try httpStatusCodeValidator(meta, data: data, httpRequired: true)
}

internal func httpStatusCodeValidator<MetadataType>(meta: MetadataType?, data: NSData?, httpRequired: Bool)
    throws
{
    guard let http = meta as? HTTPResponseMetadata else {
        if httpRequired {
            throw DataTransactionError.HTTPRequired
        } else {
            return  // assume success
        }
    }

    if http.responseStatus.isError {
        throw DataTransactionError.HTTPError(http, data)
    }
}

