//
//  JSONExtractionExtensions.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 7/28/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

extension Dictionary
{
    /**
     Retrieves a value from the dictionary using the given `JSONKey`.

     - note: Whenever the `Dictionary.Key` generic type is not `String`,
     `nil` is always returned.

     - parameter key: The key whose associated value is to be retrieved.
     
     - returns: The dictionary value associated with `key`, or `nil` if no
     such value exists.
     */
    public subscript(key: JSONKey)
        -> Dictionary.Value?
    {
        return value(key)
    }

    fileprivate func value<T>(_ key: JSONKey)
        -> T?
    {
        guard let typedKey = key.rawValue as? Dictionary.Key else { return nil }

        guard let val = self[typedKey] else { return nil }

        return val as? T
    }
}

extension Dictionary
{
    /**
     Attempts to retrieve a value of type `T` from the dictionary using the
     given `JSONKey`.

     - note: This function always throws an error whenever the `Dictionary.Key`
     generic type is not `String`.

     - parameter key: The key whose associated value is to be retrieved.

     - returns: The dictionary value (of type `T`) associated with `key`.
     
     - throws: `DataTransactionError.jsonFormatError` if the receiver does
     not contain a value of type `T` associated with `key`.
     */
    public func requiredValue<T>(_ key: JSONKey)
        throws
        -> T
    {
        guard let val: T = value(key) else {
            throw DataTransactionError.jsonFormatError("Expected to find value for key named \"\(key.rawValue)\" of type \(T.self)", self)
        }
        return val
    }

    /**
     Attempts to retrieve a `UUID` from the dictionary using the given
     `JSONKey`.

     The dictionary value is expected to be of type `String`, and in a format
     compatible with the `UUID(uuidString:)` initializer.

     - note: This function always throws an error whenever the `Dictionary.Key`
     generic type is not `String`.

     - parameter key: The key whose associated value is to be retrieved.

     - returns: The `UUID` associated with `key`.

     - throws: `DataTransactionError.jsonFormatError` if the receiver does
     not contain a `String` value associated with `key`, or if the value is
     not in a format accepted by the `UUID(uuidString:)` initializer.
     */
    public func requiredUUID(_ key: JSONKey)
        throws
        -> UUID
    {
        let uuidStr = try requiredString(key)

        guard let val = UUID(uuidString: uuidStr) else {
            throw DataTransactionError.jsonFormatError("Expected to find key named \(key.rawValue) containing a UUID string value", self)
        }
        return val
    }

    /**
     Attempts to retrieve a `Bool` value from the dictionary using the given
     `JSONKey`.

     This implementation is intended to be forgiving as far as what constitutes
     a `Bool` value.

     - note: This function always throws an error whenever the `Dictionary.Key`
     generic type is not `String`.

     - parameter key: The key whose associated value is to be retrieved.

     - returns: The `Bool` value associated with `key`.

     - throws: `DataTransactionError.jsonFormatError` if the receiver does
     not contain a value associated with `key` that can be interpreted as a 
     `Bool`.
     */
    public func requiredBool(_ key: JSONKey)
        throws
        -> Bool
    {
        guard let val = optionalBool(key) else {
            throw DataTransactionError.jsonFormatError("Expected to find key named \"\(key.rawValue)\" containing a numeric, string, or boolean Bool value", self)
        }
        return val
    }

    /**
     Attempts to retrieve a `Bool` value from the dictionary using the given
     `JSONKey`.

     This implementation is intended to be forgiving as far as what constitutes
     a `Bool` value.

     - note: This function always returns `nil` whenever the `Dictionary.Key`
     generic type is not `String`.

     - parameter key: The key whose associated value is to be retrieved.

     - returns: The `Bool` value associated with `key`, or `nil` if there is
     no value associated with `key` that can be interpreted as a `Bool`.
     */
    public func optionalBool(_ key: JSONKey)
        -> Bool?
    {
        guard let val: Any = value(key) else {
            return nil
        }
        if let bool = val as? Bool {
            return bool
        }
        else if let boolInt = val as? Int {
            return boolInt != 0
        }
        else if let boolStr = val as? String {
            return Bool(boolStr)
        }
        return nil
    }

    /**
     Attempts to retrieve an `Int` value from the dictionary using the given
     `JSONKey`.

     - note: This function always throws an error whenever the `Dictionary.Key`
     generic type is not `String`.

     - parameter key: The key whose associated value is to be retrieved.

     - returns: The `Int` value associated with `key`.

     - throws: `DataTransactionError.jsonFormatError` if the receiver does
     not contain a value associated with `key` that can be interpreted as an
     `Int`.
     */
    public func requiredInt(_ key: JSONKey)
        throws
        -> Int
    {
        return try requiredValue(key)
    }

    /**
     Attempts to retrieve an `Int32` value from the dictionary using the given
     `JSONKey`.

     - note: This function always throws an error whenever the `Dictionary.Key`
     generic type is not `String`.

     - parameter key: The key whose associated value is to be retrieved.

     - returns: The `Int32` value associated with `key`.

     - throws: `DataTransactionError.jsonFormatError` if the receiver does
     not contain a value associated with `key` that can be interpreted as an
     `Int32`.
     */
    public func requiredInt32(_ key: JSONKey)
        throws
        -> Int32
    {
        return try requiredValue(key)
    }

    /**
     Attempts to retrieve an `Int64` value from the dictionary using the given
     `JSONKey`.
     
     - note: This function always throws an error whenever the `Dictionary.Key`
     generic type is not `String`.
     
     - parameter key: The key whose associated value is to be retrieved.
     
     - returns: The `Int64` value associated with `key`.
     
     - throws: `DataTransactionError.jsonFormatError` if the receiver does
     not contain a value associated with `key` that can be interpreted as an
     `Int64`.
     */
    public func requiredInt64(_ key: JSONKey)
        throws
        -> Int64
    {
        return try requiredValue(key)
    }
    /**
     Attempts to retrieve a `Double` value from the dictionary using the given
     `JSONKey`.

     - note: This function always throws an error whenever the `Dictionary.Key`
     generic type is not `String`.

     - parameter key: The key whose associated value is to be retrieved.

     - returns: The `Double` value associated with `key`.

     - throws: `DataTransactionError.jsonFormatError` if the receiver does
     not contain a value associated with `key` that can be interpreted as a
     `Double`.
     */
    public func requiredDouble(_ key: JSONKey)
        throws
        -> Double
    {
        return try requiredValue(key)
    }

    /**
     Attempts to retrieve a `JSONArray` value from the dictionary using the
     given `JSONKey`.

     - note: This function always throws an error whenever the `Dictionary.Key`
     generic type is not `String`.

     - parameter key: The key whose associated value is to be retrieved.

     - returns: The `JSONArray` value associated with `key`.

     - throws: `DataTransactionError.jsonFormatError` if the receiver does
     not contain a value associated with `key` that can be interpreted as a
     `JSONArray`.
     */
    public func requiredArray(_ key: JSONKey)
        throws
        -> JSONArray
    {
        return try requiredArrayWithTypecast(key)
    }

    /**
     Attempts to retrieve an `Array` value whose `Element`s are of type `T`
     from the dictionary using the given `JSONKey`.

     - note: This function always throws an error whenever the `Dictionary.Key`
     generic type is not `String`.

     - parameter key: The key whose associated value is to be retrieved.

     - returns: The array of `T` values associated with `key`.

     - throws: `DataTransactionError.jsonFormatError` if the receiver does
     not contain a value associated with `key` that can be interpreted as an
     array of `T`.
     */
    public func requiredArrayWithTypecast<T>(_ key: JSONKey)
        throws
        -> [T]
    {
        guard let val: [T] = value(key) else {
            throw DataTransactionError.jsonFormatError("Expected to find key named \"\(key.rawValue)\" containing an Array<\(T.self)>", self)
        }
        return val
    }

    /**
     Attempts to retrieve an array of type `A` elements from the receiver
     using the specified `JSONKey`. If such a value exists, the given
     transform function is applied to each element in the array, yielding
     a new `Array` whose `Element`s are of type `T`. If the transform function
     fails for any element, an error is thrown.

     - note: This function always throws an error whenever the `Dictionary.Key`
     generic type is not `String`.

     - parameter key: The key whose associated value is to be retrieved.

     - parameter transform: The transform function to apply to convert `A`
     into `T`. The function throws an error when the conversion of a given
     element fails.

     - returns: The array of `T` values.

     - throws: `DataTransactionError.jsonFormatError` if the receiver does
     not contain a value associated with `key` that can be interpreted as an
     array of `A`. Any error thrown by the transform function will also be
     rethrown.
     */
    public func requiredArray<T, A>(_ key: JSONKey, withTransform transform: (A) throws -> T)
        throws
        -> [T]
    {
        let extractedArray: [A] = try requiredArrayWithTypecast(key)
        var resultArray = [T]()
        resultArray.reserveCapacity(extractedArray.count)

        for item in extractedArray {
            resultArray.append(try transform(item))
        }

        return resultArray
    }

    /**
     Attempts to retrieve an array of type `A` elements from the receiver
     using the specified `JSONKey`. If such a value exists, the given
     transform function is applied to each element in the array, yielding
     a new `Array` whose `Element`s are of type `T`. If the transform function
     fails for any element, the error is ignored and that element is omitted 
     from the returned array.

     - note: This function always throws an error whenever the `Dictionary.Key`
     generic type is not `String`.

     - parameter key: The key whose associated value is to be retrieved.

     - parameter transform: The transform function to apply to convert `A`
     into `T`. The function returns `nil` when the conversion of a given
     element fails.

     - returns: The array of `T` values.

     - throws: `DataTransactionError.jsonFormatError` if the receiver does
     not contain a value associated with `key` that can be interpreted as an
     array of `A`.
     */
    public func requiredArray<T, A>(_ key: JSONKey, withOptionalTransform transform: (A) -> T?)
        throws
        -> [T]
    {
        let extractedArray: [A] = try requiredArrayWithTypecast(key)

        return extractedArray.flatMap { transform($0) }
    }

    /**
     Attempts to retrieve an array of type `A` elements from the receiver
     using the specified `JSONKey`. If such a value exists, the given
     transform function is applied to each element in the array, yielding
     a new `Array` whose `Element`s are of type `T`. If the transform function
     fails for any element, an error is thrown.

     - note: This function always returns `nil` whenever the `Dictionary.Key`
     generic type is not `String`.

     - parameter key: The key whose associated value is to be retrieved.

     - parameter transform: The transform function to apply to convert `A`
     into `T`. The function throws an error when the conversion of a given
     element fails.

     - returns: The array of `T` values, or `nil` if there was no array of
     `A` values stored in the receiver for `key`.

     - throws: The function rethrows any error thrown by `transform`.
     */
    public func optionalArray<T, A>(_ key: JSONKey, withTransform transform: (A) throws -> T)
        throws
        -> [T]?
    {
        guard let array: [A] = value(key) else { return nil }

        return try array.map { try transform($0) }
    }

    /**
     Attempts to retrieve an array of type `A` elements from the receiver
     using the specified `JSONKey`. If such a value exists, the given
     transform function is applied to each element in the array, yielding
     a new `Array` whose `Element`s are of type `T`. If the transform function
     fails for any element, the error is ignored and that element is omitted
     from the returned array.

     - note: This function always returns `nil` whenever the `Dictionary.Key`
     generic type is not `String`.

     - parameter key: The key whose associated value is to be retrieved.

     - parameter transform: The transform function to apply to convert `A`
     into `T`. The function returns `nil` when the conversion of a given
     element fails.

     - returns: The array of `T` values, or `nil` if there was no array of
     `A` values stored in the receiver for `key`.
     */
    public func optionalArray<T, A>(_ key: JSONKey, withOptionalTransform transform: ((A) -> T?))
        -> [T]?
    {
        guard let array: [A] = value(key) else { return nil }

        return array.flatMap { transform($0) }
    }

    /**
     Attempts to retrieve a `[String]` value from the dictionary using the
     given `JSONKey`.

     - note: This function always throws an error whenever the `Dictionary.Key`
     generic type is not `String`.

     - parameter key: The key whose associated value is to be retrieved.

     - returns: The `[String]` value associated with `key`.

     - throws: `DataTransactionError.jsonFormatError` if the receiver does
     not contain a value associated with `key` that can be interpreted as a
     `[String]`.
     */
    public func requiredStringArray(_ key: JSONKey)
        throws
        -> [String]
    {
        guard let val: [String] = value(key) else {
            throw DataTransactionError.jsonFormatError("Expected to find key named \"\(key.rawValue)\" containing a [String]", self)
        }
        return val
    }

    /**
     Attempts to retrieve a `JSONDictionary` value from the dictionary using
     the given `JSONKey`.

     - note: This function always throws an error whenever the `Dictionary.Key`
     generic type is not `String`.

     - parameter key: The key whose associated value is to be retrieved.

     - returns: The `String` value associated with `key`.

     - throws: `DataTransactionError.jsonFormatError` if the receiver does
     not contain a value associated with `key` that can be interpreted as a
     `String`.
     */
    public func requiredDictionary(_ key: JSONKey)
        throws
        -> JSONDictionary
    {
        guard let val: JSONDictionary = value(key) else {
            throw DataTransactionError.jsonFormatError("Expected to find key named \"\(key.rawValue)\" containing a \(JSONDictionary.self)", self)
        }
        return val
    }

    /**
     Attempts to retrieve a `String` value from the dictionary using the given
     `JSONKey`.

     - note: This function always throws an error whenever the `Dictionary.Key`
     generic type is not `String`.

     - parameter key: The key whose associated value is to be retrieved.

     - returns: The `String` value associated with `key`.

     - throws: `DataTransactionError.jsonFormatError` if the receiver does
     not contain a value associated with `key` that can be interpreted as a
     `String`.
     */
    public func requiredString(_ key: JSONKey)
        throws
        -> String
    {
        if let val = self[key] {
            if let val = val as? String {
                return val
            }
            if let val = val as? CustomStringConvertible {
                return val.description
            }
        }
        throw DataTransactionError.jsonFormatError("Expected to find key named \"\(key.rawValue)\" containing a String (or String convertible) value", self)
    }

    /**
     Attempts to retrieve a `URL` from the dictionary using the given
     `JSONKey`.

     The dictionary value is expected to be of type `String`, and in a format
     compatible with the `URL(string:)` initializer.

     - note: This function always throws an error whenever the `Dictionary.Key`
     generic type is not `String`.

     - parameter key: The key whose associated value is to be retrieved.

     - returns: The `URL` associated with `key`.

     - throws: `DataTransactionError.jsonFormatError` if the receiver does
     not contain a `String` value associated with `key`, or if the value is
     not in a format accepted by the `URL(string:)` initializer.
     */
    public func requiredURL(_ key: JSONKey)
        throws
        -> URL
    {
        guard let url = URL(string: try requiredString(key)) else {
            throw DataTransactionError.jsonFormatError("Expected the key named \"\(key.rawValue)\" to contain a valid URL value", self)
        }
        return url
    }
}
