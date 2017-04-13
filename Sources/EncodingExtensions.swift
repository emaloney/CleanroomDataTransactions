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
     a URL path are escaped with percent encoding. */
    public var urlPathEncoded: String {
        return addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? self
    }

    /** Returns a version of the receiver in UTF-8 encoded `Data` wherein 
     characters not allowed in a URL path are escaped with percent encoding. */
    public var urlPathEncodedData: Data? {
        return urlPathEncoded.data(using: .utf8)
    }

    /** Returns a version of the receiver wherein characters that are not valid
     in HTTP form values are escaped with percent encoding. */
    public var httpFormEncoded: String {
        return addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]").inverted) ?? self
    }

    /** Returns a version of the receiver in UTF-8 encoded `Data` wherein
     characters that are not valid in HTTP form values are escaped with percent
     encoding. */
    public var httpFormEncodedData: Data? {
        return httpFormEncoded.data(using: .utf8)
    }
}

extension Dictionary
{
    /**
     Returns the contents of the receiver in a URL path encoded `String`.
     */
    public var urlPathEncoded: String {
        return encoded { $0.urlPathEncoded }
    }

    /**
     Returns UTF-8 `Data` containing a URL path encoded version of the
     receiver.
     */
    public var urlPathEncodedData: Data? {
        return urlPathEncoded.data(using: .utf8)
    }

    /**
     Returns the contents of the receiver in an HTTP form encoded `String`.
     */
   public var httpFormEncoded: String {
        return encoded { $0.httpFormEncoded }
    }

    /**
     Returns UTF-8 `Data` containing a version of the receiver encoded
     as HTTP form data.
     */
    public var httpFormEncodedData: Data? {
        return httpFormEncoded.data(using: .utf8)
    }

    private func encoded(using encodingFunction: (String) -> String)
        -> String
    {
        var encoded = [String]()
        for (key, value) in self {
            guard let keyStr = key as? String else { continue }

            if let valStr = value as? String {
                encoded += ["\(encodingFunction(keyStr))=\(encodingFunction(valStr))"]
            }
            else if let valBool = value as? Bool, valBool {
                encoded += ["\(encodingFunction(keyStr))"]
            }
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
