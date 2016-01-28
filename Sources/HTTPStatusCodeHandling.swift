 //
//  JSONPayloadProcessing.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 1/28/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation
import CleanroomConcurrency
import CleanroomLogger

public func httpStatusCodeHandler<MetadataType, DataType>(meta: MetadataType?, payload: DataType, httpRequired: Bool)
    throws
{
    guard let http = meta as? HTTPResponseMetadata else {
        if httpRequired {
            throw DataTransactionError.HTTPRequired
        } else {
            return  // assume success
        }
    }

    let status = http.responseStatus

    Log.debug?.message("HTTP \(status.statusCode): \(status)")

    if status.isErrorResponse {
        throw DataTransactionError.HTTPError(http, nil)
    }
}

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
