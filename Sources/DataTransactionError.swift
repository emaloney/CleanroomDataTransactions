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
public enum DataTransactionError: Error
{
    /** A `DataTransactionError` that wraps a generic `ErrorType`. */
    case wrappedError(Error)

    /** Contains an error message returned by a service. */
    case serviceError(String)

    /** An error indicating that data is not in the expected format. Contains
     a message with additional details. */
    case dataFormatError(String)

    /** An error indicating that JSON data is not in the expected format.
     Contains a message with additional details, as well as an optional
     object instance containing the source data of the JSON. */
    case jsonFormatError(String, Any?)

    /** The execution path taken by a `DataTransaction` has not been fully
     implemented. */
    case notImplemented

    /** The resource requested by the `DataTransaction` is not available. */
    case notAvailable

    /** The transaction protocol has been implemented incorrectly. */
    case badImplementation

    /** Transaction processing encountered an unexpected type. */
    case incompatibleType

    /** Failed to create a `URLSessionTask` for the transaction. */
    case sessionTaskNotCreated

    /** Use of the HTTP protocol is required for the given transaction, but
     it was not used. */
    case httpRequired

    /** The transaction could not be initiated because the request has no
     `URL`. */
    case noURL

    /** The transaction returned no data. */
    case noData

    /** The transaction was canceled or deallocated before it could be
     completed. */
    case canceled

    /** The transaction is already in the process of being executed and
     has not yet returned. */
    case alreadyInFlight

    /** The transaction was aborted because it did not complete in a reasonable
     time. */
    case timeout

    /** The transaction expired before it completed. */
    case expired

    /** The given string could not be converted into a `URL` instance. */
    case invalidURL(String)

    /** An unexpected HTTP response code was returned for the transaction. */
    case unexpectedHTTPResponseCode(Int)

    /** Indicates that the caller is not authorized to perform the given 
     transaction. */
    case notAuthorized

    /** Indicates an HTTP error response was received. Contains the response,
     its metadata, and the body of the response. */
    case httpError(HTTPURLResponse, HTTPResponseMetadata, Data)
}

extension DataTransactionError
{
    /**
     Returns a `DataTransactionError` representing the given `ErrorType`.

     - parameter error: The `ErrorType` to (possibly) wrap. If `error` is
     already a `DataTransactionError`, it is simply returned as-is. Otherwise,
     `.WrappedError(error)` is returned.
     */
    public static func wrap(_ error: Error)
        -> DataTransactionError
    {
        if let error = error as? DataTransactionError {
            return error
        } else {
            return .wrappedError(error)
        }
    }
}

extension DataTransactionError: CustomStringConvertible
{
    /** A string representation of the `DataTransactionError`. */
    public var description: String {
        switch self {
        case .wrappedError(let error):
            return "\(error)"

        case .serviceError(let errorDescription):
            return "Service error: \(errorDescription)"

        case .dataFormatError(let errorDescription):
            return "Data format error: \(errorDescription)"

        case .jsonFormatError(let errorDescription, _):
            return "JSON error: \(errorDescription)"

        case .notImplemented:
            return "Nobody has written the code for the thing you’re trying to do."

        case .notAvailable:
            return "What you seek does not exist or is not currently available."

        case .badImplementation:
            return "Something isn’t right; in fact, one might go so far as to say that something is wrong."

        case .incompatibleType:
            return "The implementation encountered a type it wasn't expecting, and can't handle because it is not compatible."

        case .sessionTaskNotCreated:
            return "Could not create the task needed to perform this operation."

        case .httpRequired:
            return "HTTP is required for this operation"

        case .noData:
            return "No data was returned for the request being processed."
            
        case .noURL:
            return "The transaction could not be initiated because the request has no URL."
            
        case .canceled:
            return "The request was canceled or deallocated."

        case .alreadyInFlight:
            return "The thing you are trying to do is already being done."

        case .timeout:
            return "Been waiting too long; have given up."

        case .expired:
            return "The time-limited resource is no longer valid."

        case .invalidURL(let urlString):
            return "This does not appear to be a valid URL: \(urlString)"

        case .unexpectedHTTPResponseCode(let code):
            return "Received an HTTP response code (\(code)) that wasn't expected."

        case .notAuthorized:
            return "Not authorized to access this resource."

        case .httpError(_, let meta, let data):
            if !data.isEmpty {
                let dataStr = data.asStringUTF8 ?? "(data could not be converted to a UTF-8 string)"
                return "HTTP error \(meta.responseStatusCode) returned by \(meta.issuedURL) with \(data.count) bytes of data: \(dataStr)"
            } else {
                return "HTTP error \(meta.responseStatusCode) returned by \(meta.issuedURL)"
            }
        }
    }
}

