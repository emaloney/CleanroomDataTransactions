//
//  JSONPayloadProcessing.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 1/28/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

public func httpOptionalStatusCodeHandler<MetadataType, DataType>(meta: MetadataType?, payload: DataType)
    throws
{
    try httpStatusCodeHandler(meta, payload: payload, httpRequired: false)
}

public func httpRequiredStatusCodeHandler<MetadataType, DataType>(meta: MetadataType?, payload: DataType)
    throws
{
    try httpStatusCodeHandler(meta, payload: payload, httpRequired: true)
}

internal func httpStatusCodeHandler<MetadataType, DataType>(meta: MetadataType?, payload: DataType, httpRequired: Bool)
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
        throw DataTransactionError.HTTPError(http, nil)
    }
}

