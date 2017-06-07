//
//  MIMEType.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 6/6/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

/**
 Allows MIME types to be declared statically at compile-time, enabling them to 
 be referenced in a "non-stringly" way.
 */
public struct MIMEType
{
    /** A `String` representation of the `MIMEType`. */
    public let rawValue: String

    /**
     Constructs a new `MIMEType` using the given string.

     - parameter type: `StaticString` containing the MIME type string.
     */
    public init(_ type: StaticString)
    {
        self.rawValue = type.description
    }
}

extension MIMEType
{
    /** Represents the MIME type "`application/x-www-form-urlencoded`". */
    public static let urlFormEncoded    = MIMEType("application/x-www-form-urlencoded")

    /** Represents the MIME type "`application/json`". */
    public static let json              = MIMEType("application/json")
}
