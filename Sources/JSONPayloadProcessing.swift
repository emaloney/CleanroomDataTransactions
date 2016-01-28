//
//  JSONPayloadProcessing.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 1/28/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

public func simplePayloadProcessor<T>(jsonObject: AnyObject?)
    throws
    -> T
{
    guard let typed = jsonObject as? T else {
        throw DataTransactionError.DataFormatError("Expecting JSON data to be a type of \(T.self); got \(jsonObject.dynamicType) instead")
    }
    return typed
}

public func optionalPayloadProcessor<T>(jsonObject: AnyObject?)
    throws
    -> T?
{
    guard let object = jsonObject else {
        return nil
    }

    guard let typed = object as? T else {
        throw DataTransactionError.DataFormatError("Expecting JSON data to be a type of \(T.self); got \(object.dynamicType) instead")
    }

    return typed
}
