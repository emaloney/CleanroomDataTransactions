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
 
 - parameter data: An optional `Data` instance containing the transaction's
 raw response body.

 - throws: `DataTransactionError.HTTPError` if `meta` is an instance of
 `HTTPResponseMetadata` that represents either a client or server error.
 */
public func httpOptionalStatusCodeValidator<MetadataType>(metadata: MetadataType?, data: Data?)
    throws
{
    try httpStatusCodeValidator(metadata: metadata, data: data, httpRequired: false)
}

/**
 A `MetadataValidationFunction` that expects its `MetadataType` to be an
 instance of `HTTPResponseMetadata`.

 - parameter meta: An optional `MetadataType`.

 - parameter data: An optional `Data` instance containing the transaction's
 raw response body.

 - throws: `DataTransactionError.HTTPRequired` if `meta` is not an instance
 of `HTTPResponseMetadata`.
 
 - throws: `DataTransactionError.HTTPError` if `meta` is an instance of
 `HTTPResponseMetadata` that represents either a client or server error.
 */
public func httpRequiredStatusCodeValidator<MetadataType>(metadata: MetadataType?, data: Data?)
    throws
{
    try httpStatusCodeValidator(metadata: metadata, data: data, httpRequired: true)
}

internal func httpStatusCodeValidator<MetadataType>(metadata: MetadataType?, data: Data?, httpRequired: Bool)
    throws
{
    guard let http = metadata as? HTTPResponseMetadata else {
        if httpRequired {
            throw DataTransactionError.httpRequired
        } else {
            return  // assume success
        }
    }

    if http.responseStatus.isError {
        throw DataTransactionError.httpError(http, data)
    }
}

