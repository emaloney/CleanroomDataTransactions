//
//  JSONPayloadProcessing.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 1/28/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

/**
 A `PayloadProcessingFunction` that requires `jsonObject` to be an instance
 of type `T`.
 
 - parameter jsonObject: An object created from a JSON data structure.
 
 - returns: An instance of type `T`.

 - throws: A `DataTransactionError` if `jsonObject` could not be cast to
 type `T`.
 */
public func requiredPayloadProcessor<T>(_ jsonObject: AnyObject?)
    throws
    -> T
{
    guard let typed = jsonObject as? T else {
        throw DataTransactionError.dataFormatError("Expecting JSON data to be a type of \(T.self); got \(jsonObject.dynamicType) instead")
    }
    return typed
}

/**
 A `PayloadProcessingFunction` that accepts an optional `jsonObject` expected
 to be of type `T`.

 - parameter jsonObject: An optional object created from a JSON data structure.

 - returns: An instance of type `T`, or `nil` if `jsonObject` is `nil`.

 - throws: A `DataTransactionError` if `jsonObject` is non-`nil` and could not
 be cast to type `T`.
 */
public func optionalPayloadProcessor<T>(_ jsonObject: AnyObject?)
    throws
    -> T?
{
    guard let object = jsonObject else {
        return nil
    }

    guard let typed = object as? T else {
        throw DataTransactionError.dataFormatError("Expecting JSON data to be a type of \(T.self); got \(object.dynamicType) instead")
    }

    return typed
}
