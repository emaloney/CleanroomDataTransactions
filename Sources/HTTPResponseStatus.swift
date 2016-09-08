//
//  HTTPResponseStatus.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 1/28/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 Meaningful values for some of the common HTTP response codes.
 
 Note that not every HTTP code is represented here; those that aren't
 can be stored in the `.Other` case.
 */
public enum HTTPResponseStatus
{
    /** The `200 OK` response code. */
    case ok

    /** The `201 Created` response code. */
    case created

    /** The `204 No Content` response code. */
    case noContent

    /** The `400 Bad Request` response code. */
    case badRequest

    /** The `401 Unauthorized` response code. */
    case unauthorized

    /** The `404 Not Found` response code. */
    case notFound

    /** The `409 Conflict` response code. */
    case conflict

    /** The `410 Gone` response code. */
    case gone

    /** The `422 Unprocessable Entity` response code. */
    case unprocessableEntity

    /** The `502 Bad Gateway` response code. */
    case badGateway

    /** Represents HTTP response codes not covered by the other cases. */
    case other(Int)

    /** The numeric HTTP status code. */
    public var statusCode: Int {
        switch self {
        case .ok:                   return 200
        case .created:              return 201
        case .noContent:            return 204
        case .badRequest:           return 400
        case .unauthorized:         return 401
        case .notFound:             return 404
        case .conflict:             return 409
        case .gone:                 return 410
        case .unprocessableEntity:  return 422
        case .badGateway:           return 502
        case .other(let code):      return code
        }
    }

    /**
     Initializes an `HTTPResponseStatus` to the value represented by the given
     `Int`.
     
     - parameter statusCode: The HTTP status code.
     */
    public init(_ statusCode: Int)
    {
        switch statusCode {
        case 200:	self = .ok
        case 201:	self = .created
        case 204:	self = .noContent
        case 400:	self = .badRequest
        case 401:	self = .unauthorized
        case 404:	self = .notFound
        case 409:	self = .conflict
        case 410:	self = .gone
        case 422:	self = .unprocessableEntity
        case 502:	self = .badGateway
        case _:     self = .other(statusCode)
        }
    }
}

extension HTTPResponseStatus
{
    /**
     Represents the five categories of HTTP response codes.
     */
    public enum Category {
        /** Indicates an informational (`1xx`) response, possibly pending
         further information. */
        case informational

        /** Indicates an successful (`2xx`) response. */
        case success

        /** Indicates a redirect (`3xx`) response. */
        case redirection

        /** Indicates a client error (`4xx`) response. */
        case clientError

        /** Indicates a server error (`5xx`) response, or a response with an
         error code not falling into one of the ranges above.  */
        case serverError
    }

    /** Indicates the category of the HTTP response. */
    public var responseCategory: Category {
        switch statusCode {
        case 100..<200: return .informational
        case 200..<300: return .success
        case 300..<400: return .redirection
        case 400..<500: return .clientError
        case _:         return .serverError
        }
    }
}

extension HTTPResponseStatus
{
    /** Indicates whether the receiver's `responseCategory` is 
     `.Informational`. */
    public var isInformational: Bool { return responseCategory == .informational }

    /** Indicates whether the receiver's `responseCategory` is
     `.Success`. */
    public var isSuccess: Bool { return responseCategory == .success }

    /** Indicates whether the receiver's `responseCategory` is
     `.Redirection`. */
    public var isRedirect: Bool { return responseCategory == .redirection }

    /** Indicates whether the receiver's `responseCategory` is
     `.ClientError`. */
    public var isClientError: Bool { return responseCategory == .clientError }

    /** Indicates whether the receiver's `responseCategory` is
     `.ServerError`. */
    public var isServerError: Bool { return responseCategory == .serverError }

    /** Indicates whether the receiver represents a `.ClientError` or
     `.ServerError`. */
    public var isError: Bool { return isClientError || isServerError }
}
