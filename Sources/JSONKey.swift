//
//  JSONKey.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 7/28/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

/**
 Allows keys to be declared statically at compile-time, enabling them to be
 referenced in a "non-stringly" way.
 */
public struct JSONKey
{
    /** The `StaticString` used to declare the `JSONKey` at compile-time. */
    public let key: StaticString

    /** A `String` representation of the `JSONKey`. */
    public let rawValue: String

    /** 
     Constructs a new `JSONKey` using the given key.
     
     - parameter key: `StaticString` containing the key.
     */
    public init(_ key: StaticString)
    {
        self.key = key
        self.rawValue = key.description
    }
}
