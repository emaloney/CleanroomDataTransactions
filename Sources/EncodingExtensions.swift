//
//  EncodingExtensions.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 10/17/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

public extension String
{
    public var stringByUrlPathEncoding: String {
        return addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? self
    }

    public var dataByUrlPathEncoding: Data? {
        return stringByUrlPathEncoding.data(using: .utf8)
    }

    public var stringByHttpFormEncoding: String {
        return addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]").inverted) ?? self
    }

    public var dataByHttpFormEncoding: Data? {
        return stringByHttpFormEncoding.data(using: .utf8)
    }
}

public extension Dictionary
{
    public var stringByUrlPathEncoding: String {
        var encoded = [String]()
        for (key, value) in self {
            guard let keyStr = key as? String else { continue }

            if let valStr = value as? String {
                encoded += ["\(keyStr.stringByUrlPathEncoding)=\(valStr.stringByUrlPathEncoding)"]
            }
            else if let valBool = value as? Bool, valBool {
                encoded += ["\(keyStr.stringByUrlPathEncoding)"]
            }
        }
        return encoded.joined(separator: "&")
    }

    public var dataByUrlPathEncoding: Data? {
        return stringByUrlPathEncoding.data(using: .utf8)
    }

    public var stringByHttpFormEncoding: String {
        var encoded = [String]()
        for (key, value) in self {
            guard let keyStr = key as? String else { continue }

            if let valStr = value as? String {
                encoded += ["\(keyStr.stringByHttpFormEncoding)=\(valStr.stringByHttpFormEncoding)"]
            }
            else if let valBool = value as? Bool, valBool {
                encoded += ["\(keyStr.stringByHttpFormEncoding)"]
            }
        }
        return encoded.joined(separator: "&")
    }

    public var dataByHttpFormEncoding: Data? {
        return stringByHttpFormEncoding.data(using: .utf8)
    }
}
