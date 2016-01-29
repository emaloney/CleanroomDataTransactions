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
    case OK

    /** The `201 Created` response code. */
    case Created

    /** The `204 No Content` response code. */
    case NoContent

    /** The `400 Bad Request` response code. */
    case BadRequest

    /** The `401 Unauthorized` response code. */
    case Unauthorized

    /** The `404 Not Found` response code. */
    case NotFound

    /** The `409 Conflict` response code. */
    case Conflict

    /** The `410 Gone` response code. */
    case Gone

    /** The `422 Unprocessable Entity` response code. */
    case UnprocessableEntity

    /** The `502 Bad Gateway` response code. */
    case BadGateway

    /** Represents HTTP response codes not covered by the other cases. */
    case Other(Int)

    /** The numeric HTTP status code. */
    public var statusCode: Int {
        switch self {
        case OK:                    return 200
        case Created:               return 201
        case NoContent:             return 204
        case BadRequest:            return 400
        case Unauthorized:          return 401
        case NotFound:              return 404
        case Conflict:              return 409
        case Gone:                  return 410
        case UnprocessableEntity:	return 422
        case BadGateway:            return 502
        case Other(let code):       return code
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
        case 200:	self = OK
        case 201:	self = Created
        case 204:	self = NoContent
        case 400:	self = BadRequest
        case 401:	self = Unauthorized
        case 404:	self = NotFound
        case 409:	self = Conflict
        case 410:	self = Gone
        case 422:	self = UnprocessableEntity
        case 502:	self = BadGateway
        default:    self = Other(statusCode)
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
        case Informational

        /** Indicates an successful (`2xx`) response. */
        case Success

        /** Indicates a redirect (`3xx`) response. */
        case Redirection

        /** Indicates a client error (`4xx`) response. */
        case ClientError

        /** Indicates a server error (`5xx`) response, or a response with an
         error code not falling into one of the ranges above.  */
        case ServerError
    }

    /** Indicates the category of the HTTP response. */
    public var responseCategory: Category {
        switch statusCode {
        case 100..<200: return .Informational
        case 200..<300: return .Success
        case 300..<400: return .Redirection
        case 400..<500: return .ClientError
        default:        return .ServerError
        }
    }
}

extension HTTPResponseStatus
{
    /** Indicates whether the receiver's `responseCategory` is 
     `.Informational`. */
    public var isInformational: Bool { return responseCategory == .Informational }

    /** Indicates whether the receiver's `responseCategory` is
     `.Success`. */
    public var isSuccess: Bool { return responseCategory == .Success }

    /** Indicates whether the receiver's `responseCategory` is
     `.Redirection`. */
    public var isRedirect: Bool { return responseCategory == .Redirection }

    /** Indicates whether the receiver's `responseCategory` is
     `.ClientError`. */
    public var isClientError: Bool { return responseCategory == .ClientError }

    /** Indicates whether the receiver's `responseCategory` is
     `.ServerError`. */
    public var isServerError: Bool { return responseCategory == .ServerError }

    /** Indicates whether the receiver represents a `.ClientError` or
     `.ServerError`. */
    public var isError: Bool { return isClientError || isServerError }
}
