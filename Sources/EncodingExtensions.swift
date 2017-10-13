//
//  EncodingExtensions.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 10/17/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

extension String
{
    /** Returns a version of the receiver wherein characters not allowed in
     the path component of a URL are escaped with percent encoding. */
    public var urlPathEncoded: String {
        return addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? self
    }

    /** Returns a version of the receiver in UTF-8 encoded `Data` wherein 
     characters not allowed in the path component of a URL are escaped with
     percent encoding. */
    public var urlPathEncodedData: Data {
        return urlPathEncoded.utf8Data
    }

    /** Returns a version of the receiver wherein characters not allowed in
     the query string of a URL are escaped with percent encoding. */
    public var urlQueryEncoded: String {
        return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }

    /** Returns a version of the receiver in UTF-8 encoded `Data` wherein 
     characters not allowed in the query string of a URL are escaped with 
     percent encoding. */
    public var urlQueryEncodedData: Data {
        return urlQueryEncoded.utf8Data
    }

    /** Returns a version of the receiver wherein characters that are not valid
     in HTTP form values are escaped with percent encoding. This format is
     typically used with the `application/x-www-form-urlencoded` MIME type. */
    public var urlFormEncoded: String {
        return addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]").inverted) ?? self
    }

    /** Returns a version of the receiver in UTF-8 encoded `Data` wherein
     characters that are not valid in HTTP form values are escaped with percent
     encoding. This format is typically used with the 
     `application/x-www-form-urlencoded` MIME type. */
    public var urlFormEncodedData: Data {
        return urlFormEncoded.utf8Data
    }

    /** Returns a version of the receiver in UTF-8 encoded `Data`. */
    public var utf8Data: Data {
        return data(using: .utf8, allowLossyConversion: true)!  // lossy shouldn't ever happen with UTF8
    }
}

extension Dictionary where Key == String
{
    /** Encodes the receiver as a URL path encoded `String`. */
    public var urlPathEncoded: String {
        return encoded { $0.urlPathEncoded }
    }

    /** Encodes the receiver as URL path encoded `Data` containing
     UTF-8 characters. */
    public var urlPathEncodedData: Data {
        return urlPathEncoded.utf8Data
    }

    /** Encodes the receiver as a query string encoded `String`. */
    public var urlQueryEncoded: String {
        return encoded { $0.urlQueryEncoded }
    }

    /** Encodes the receiver as query string encoded `Data` containing
     UTF-8 characters. */
    public var urlQueryEncodedData: Data {
        return urlQueryEncoded.utf8Data
    }

    /** Encodes the receiver as a URL form encoded `String`. */
    public var urlFormEncoded: String {
        return encoded { $0.urlFormEncoded }
    }

    /** Encodes the receiver as URL form encoded `Data` containing
     UTF-8 characters. */
    public var urlFormEncodedData: Data {
        return urlFormEncoded.utf8Data
    }

    private func encode(key: String, value: Any, using encodingFunction: (String) -> String, storeIn encoded: inout [String])
    {
        if let valStr = value as? String {
            encoded += ["\(encodingFunction(key))=\(encodingFunction(valStr))"]
        }
        else if let valBool = value as? Bool, valBool {
            encoded += [encodingFunction(key)]
        }
        else if let dict = value as? [String: Any] {
            for (innerKey, innerVal) in dict {
                encode(key: "\(key)[\(innerKey)]", value: innerVal, using: encodingFunction, storeIn: &encoded)
            }
        }
        else if let array = value as? [String] {
            array.forEach {
                encode(key: key, value: $0, using: encodingFunction, storeIn: &encoded)
            }
        }
        else if let valConv = value as? LosslessStringConvertible {
            encoded += ["\(encodingFunction(key))=\(encodingFunction(valConv.description))"]
        }
        else {
            encoded += ["\(encodingFunction(key))=\(encodingFunction(String(describing: value)))"]
        }
    }

    private func encoded(using encodingFunction: (String) -> String)
        -> String
    {
        var encoded = [String]()
        for (key, value) in self {
            encode(key: key, value: value, using: encodingFunction, storeIn: &encoded)
        }
        return encoded.joined(separator: "&")
    }
}

extension Dictionary
{
    /** Encodes the receiver as JSON `Data`. */
    public var jsonEncodedData: Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [])
    }
}

extension Array
{
    /** Encodes the receiver as JSON `Data`. */
    public var jsonEncodedData: Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [])
    }
}

extension Data
{
    /** Encodes the receiver as a UTF-8 `String`. */
    public var asStringUTF8: String? {
        return String(data: self, encoding: .utf8)
    }
}
