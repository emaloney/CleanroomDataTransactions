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
    /** A `DataTransactionError` that wraps a generic `ErrorType`. */
    case WrappedError(ErrorType)

    /** Contains an error message returned by a service. */
    case ServiceError(String)

    /** An error indicating that data is not in the expected format. Contains
     a message with additional details. */
    case DataFormatError(String)

    /** An error indicating that JSON data is not in the expected format.
     Contains a message with additional details, as well as an optional
     object instance containing the erroneous JSON. */
    case JSONFormatError(String, AnyObject?)

    /** The execution path taken by a `DataTransaction` has not been fully
     implemented. */
    case NotImplemented

    /** The resource requested by the `DataTransaction` is not available. */
    case NotAvailable

    /** The transaction protocol has been implemented incorrectly. */
    case BadImplementation

    /** Failed to create an `NSURLSessionTask` for the transaction. */
    case SessionTaskNotCreated

    /** Use of the HTTP protocol is required for the given transaction, but
     it was not used. */
    case HTTPRequired

    /** The transaction returned no data. */
    case NoData

    /** The transaction was canceled or deallocated before it could be
     completed. */
    case Canceled

    /** The transaction is already in the process of being executed and
     has not yet returned. */
    case AlreadyInFlight

    /** The transaction was aborted because it did not complete in a reasonable
     time. */
    case Timeout

    /** The transaction expired before it completed. */
    case Expired

    /** The given string could not be converted into an `NSURL` instance. */
    case InvalidURL(String)

    /** An unexpected HTTP response code was returned for the transaction. */
    case UnexpectedHTTPResponseCode

    /** Indicates that the caller is not authorized to perform the given 
     transaction. */
    case NotAuthorized

    /** Indicates an HTTP error response was received. Contains the metadata
     of the response as well as any response data. */
    case HTTPError(HTTPResponseMetadata, NSData?)
}

extension DataTransactionError
{
    /**
     Returns a `DataTransactionError` representing the given `ErrorType`.

     - parameter error: The `ErrorType` to (possibly) wrap. If `error` is
     already a `DataTransactionError`, it is simply returned as-is. Otherwise,
     `.WrappedError(error)` is returned.
     */
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
    /** A string representation of the `DataTransactionError`. */
    public var description: String {
        switch self {
        case .WrappedError(let error):
            return "\(error)"

        case .ServiceError(let errorDescription):
            return "Service error: \(errorDescription)"

        case .DataFormatError(let errorDescription):
            return "Data format error: \(errorDescription)"

        case .JSONFormatError(let errorDescription, _):
            return "JSON error: \(errorDescription)"

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

