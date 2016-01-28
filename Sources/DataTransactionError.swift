//
//  DataTransactionError.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 9/24/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 An `ErrorType` that represents various errors that can occur when executing
 `DataTransaction`s.
 */
public enum DataTransactionError: ErrorType
{
    case WrappedError(ErrorType)
    case UnknownError(String)
    case DataFormatError(String)
    case NotImplemented
    case NotAvailable
    case BadImplementation
    case SessionTaskNotCreated
    case HTTPRequired
    case NoData
    case Canceled
    case AlreadyInFlight
    case Timeout
    case Expired
    case InvalidSlug
    case InvalidURL(String)
    case UnexpectedHTTPResponseCode
    case NotAuthorized
    case HTTPError(HTTPResponseMetadata, NSData?)
}

extension DataTransactionError
{
    public static func wrap(error: ErrorType)
        -> DataTransactionError
    {
        if let error = error as? DataTransactionError {
            return error
        } else {
            return .WrappedError(error)
        }
    }
}

extension DataTransactionError: CustomStringConvertible
{
    public var description: String {
        switch self {
        case .WrappedError(let error):
            return "\(error)"

        case .UnknownError(let errorDescription):
            return errorDescription

        case .DataFormatError(let errorDescription):
            return "Data format error: \(errorDescription)"

        case .NotImplemented:
            return "Nobody has written the code for the thing you’re trying to do."

        case .NotAvailable:
            return "What you seek does not exist or is not currently available."

        case .BadImplementation:
            return "Something isn’t right; in fact, one might go so far as to say that something is wrong."

        case .SessionTaskNotCreated:
            return "Could not create the task needed to perform this operation."

        case .HTTPRequired:
            return "HTTP is required for this operation"

        case .NoData:
            return "No data was returned for the request being processed."

        case .Canceled:
            return "The request was canceled or deallocated."

        case .AlreadyInFlight:
            return "The thing you are trying to do is already being done."

        case .Timeout:
            return "Been waiting too long; have given up."

        case .Expired:
            return "The time-limited resource is no longer valid."

        case .InvalidSlug:
            return "No entity exists with the given slug."

        case .InvalidURL(let urlString):
            return "This does not appear to be a valid URL: \(urlString)"

        case .UnexpectedHTTPResponseCode:
            return "Received an HTTP response code that wasn't expected."

        case .NotAuthorized:
            return "Not authorized to access this resource."

        case HTTPError(let meta, _):
            return "HTTP protocol error \(meta.responseStatusCode): \(meta.responseStatus)"
        }
    }
}

