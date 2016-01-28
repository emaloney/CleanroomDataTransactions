//
//  JSONPayloadProcessing.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 1/28/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 A `JSONPayloadProcessor` that requires `jsonObject` to be an instance
 of type `T`.
 
 - parameter jsonObject: An object created from a JSON data structure.
 
 - throws: A `DataTransactionError` if `jsonObject` could not be cast to
 type `T`.
 */
public func requiredPayloadProcessor<T>(jsonObject: AnyObject?)
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
