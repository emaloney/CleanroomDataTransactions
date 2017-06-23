//
//  HTTPRequestMethod.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 11/11/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 Represents the HTTP method used to issue a request.
 */
public enum HTTPRequestMethod
{
    /** Represents the HTTP `GET` method. */
    case get

    /** Represents the HTTP `HEAD` method. */
    case head

    /** Represents the HTTP `POST` method. */
    case post

    /** Represents the HTTP `PUT` method. */
    case put

    /** Represents the HTTP `PATCH` method. */
    case patch

    /** Represents the HTTP `DELETE` method. */
    case delete

    /** Represents the HTTP `OPTIONS` method. */
    case options

    /** Represents the HTTP `TRACE` method. */
    case trace

    /** Represents the HTTP `CONNECT` method. */
    case connect

    /** Represents any HTTP method not covered by the other `case`s. */
    case unknown(String)

    fileprivate init(string: String)
    {
        switch string.uppercased() {
        case "GET":         self = .get
        case "HEAD":        self = .head
        case "POST":        self = .post
        case "PUT":         self = .put
        case "PATCH":       self = .patch
        case "DELETE":      self = .delete
        case "OPTIONS":     self = .options
        case "TRACE":       self = .trace
        case "CONNECT":     self = .connect
        default:            self = .unknown(string)
        }
    }

    /**
     Returns a string representation of the `HTTPRequestMethod`. This is
     always the fully-uppercased version of its name.
     */
    public var asString: String {
        switch self {
        case .get:              return "GET"
        case .head:             return "HEAD"
        case .post:             return "POST"
        case .put:              return "PUT"
        case .patch:            return "PATCH"
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
    /**
     The `HTTPRequestMethod` of the receiving `URLRequest`, or `nil` if one
     hasn't yet been set.
     */
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
