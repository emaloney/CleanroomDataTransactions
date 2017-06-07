//
//  HTTPRequestMethod.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 11/11/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

public enum HTTPRequestMethod
{
    case get
    case head
    case post
    case put
    case delete
    case options
    case trace
    case connect
    case unknown(String)

    fileprivate init(string: String)
    {
        switch string {
        case "GET":         self = .get
        case "HEAD":        self = .head
        case "POST":        self = .post
        case "PUT":         self = .put
        case "DELETE":      self = .delete
        case "OPTIONS":     self = .options
        case "TRACE":       self = .trace
        case "CONNECT":     self = .connect
        default:            self = .unknown(string)
        }
    }

    public var asString: String {
        switch self {
        case .get:              return "GET"
        case .head:             return "HEAD"
        case .post:             return "POST"
        case .put:              return "PUT"
        case .delete:           return "DELETE"
        case .options:          return "OPTIONS"
        case .trace:            return "TRACE"
        case .connect:          return "CONNECT"
        case .unknown(let str): return str
        }
    }
}

extension URLRequest
{
    public var httpRequestMethod: HTTPRequestMethod? {
        set {
            httpMethod = newValue?.asString
        }

        get {
            guard let httpMethod = httpMethod else {
                return nil
            }
            return HTTPRequestMethod(string: httpMethod)
        }
    }
}
