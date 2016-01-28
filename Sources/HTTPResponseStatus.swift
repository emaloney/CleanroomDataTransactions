//
//  HTTPResponseStatus.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 1/28/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

public enum HTTPResponseStatus
{
    case OK
    case Created
    case NoContent
    case BadRequest
    case Unauthorized
    case NotFound
    case Conflict
    case Gone
    case UnprocessableEntity
    case BadGateway
    case Other(Int)

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
    public enum Category {
        case Informational
        case Success
        case Redirection
        case ClientError
        case ServerError
    }

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
    public var isErrorResponse: Bool {
        switch responseCategory {
        case .ClientError, .ServerError:    return true
        default:                            return false
        }
    }
}
