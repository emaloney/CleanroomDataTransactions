//
//  HTTPTransactionTracer.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 7/25/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 Used to trace the execution of `HTTPTransaction`s from beginning to end.
 */
public protocol HTTPTransactionTracer: class
{
    /**
     Called to notify the tracer that the given `HTTPTransaction` is about to
     be executed.
     
     If this is called with a given `transactionID`, it will (eventually) be
     balanced by a call to `didComplete(transaction:result:meta:id)`.
     Additional trace functions may or may not be called depending on
     what happens with the transaction at runtime.

     - parameter transaction: The `HTTPTransaction` being reported to the
     tracer.
     
     - parameter transactionID: A unique identifier for this particular
     execution of `transaction`. As `transaction` executes a single time,
     the `transactionID` can be used to correlate different calls to the
     tracer.
     */
    func willExecute<T>(transaction: HTTPTransaction<T>, id transactionID: UUID)

    /**
     Called after a `URLRequest` for the given transaction has been fully
     configured, and just before the request is about to be issued.
     
     - parameter request: The fully-configured `URLRequest` as it will be
     issued.

     - parameter transaction: The `HTTPTransaction` being reported to the
     tracer.

     - parameter transactionID: A unique identifier for this particular
     execution of `transaction`. As `transaction` executes a single time,
     the `transactionID` can be used to correlate different calls to the
     tracer.
     */
    func didConfigure<T>(request: URLRequest, for transaction: HTTPTransaction<T>, id transactionID: UUID)

    /**
     Called when the issuance of a `URLRequest` is delayed because the
     network is not available.

     On iOS 11+, if a transaction is configured via its `sessionConfiguration`
     property to `waitForConnectivity`, transactions will be delayed for up
     to `timeout` seconds waiting for the network to become available.

     - parameter request: The `URLRequest` to be issued if the transaction
     is eventually executed.

     - parameter transaction: The `HTTPTransaction` being reported to the
     tracer.

     - parameter timeout: The maximum number of seconds that `transaction`
     will wait for network connectivity to become available before failing with
     an error.

     - parameter transactionID: A unique identifier for this particular
     execution of `transaction`. As `transaction` executes a single time,
     the `transactionID` can be used to correlate different calls to the
     tracer.

     - note: This function is _only_ called when running on iOS 11 or higher.
     */
    func willWaitForNetwork<T>(request: URLRequest, for transaction: HTTPTransaction<T>, timeout: TimeInterval, id transactionID: UUID)

    /**
     Called after a `URLRequest` has been issued, but before any sort of
     response has been received.

     Note that the transaction may complete prior to receiving an HTTP 
     response if an error occurs before then. As a result, a call to
     this function may not necessarily be balanced by a call to
     `didReceive(response:to:for:meta:data:id:)`.

     - parameter request: The `URLRequest` as it was issued.

     - parameter transaction: The `HTTPTransaction` being reported to the
     tracer.

     - parameter transactionID: A unique identifier for this particular
     execution of `transaction`. As `transaction` executes a single time,
     the `transactionID` can be used to correlate different calls to the
     tracer.
     */
    func didIssue<T>(request: URLRequest, for transaction: HTTPTransaction<T>, id transactionID: UUID)

    /**
     Called after an `HTTPURLResponse` has been received in response to a
     prior `URLRequest` being issued.
     
     Note that the response may contain an HTTP error code.

     - parameter response: The `HTTPURLResponse` received in response to
     `request`.

     - parameter request: The `URLRequest`.

     - parameter transaction: The `HTTPTransaction` being reported to the
     tracer.

     - parameter meta: An `HTTPResponseMetadata` instance containing details
     about the HTTP response.
     
     - parameter data: A `Data` instance containing the body of the HTTP
     response, in unparsed binary form.

     - parameter transactionID: A unique identifier for this particular
     execution of `transaction`. As `transaction` executes a single time,
     the `transactionID` can be used to correlate different calls to the
     tracer.
     */
    func didReceive<T>(response: HTTPURLResponse, to request: URLRequest, for transaction: HTTPTransaction<T>, meta: HTTPResponseMetadata, data: Data, id transactionID: UUID)

    /**
     Called after the `HTTPURLResponse` has been successfully validated.
     
     Although response validation can be configured by supplying a custom
     `ResponseValidator` to an `HTTPTransaction`, the default implementation
     enforces that the response does not represent an HTTP error of some kind.
     In such cases, this function is called only when the HTTP response is
     known to be a non-error.

     - parameter response: The `HTTPURLResponse` received in response to
     `request`.

     - parameter request: The `URLRequest`.

     - parameter transaction: The `HTTPTransaction` being reported to the
     tracer.

     - parameter meta: An `HTTPResponseMetadata` instance containing details
     about the HTTP response.

     - parameter data: A `Data` instance containing the body of the HTTP
     response, in unparsed binary form.

     - parameter transactionID: A unique identifier for this particular
     execution of `transaction`. As `transaction` executes a single time,
     the `transactionID` can be used to correlate different calls to the
     tracer.
     */
    func didValidate<T>(response: HTTPURLResponse, to request: URLRequest, for transaction: HTTPTransaction<T>, meta: HTTPResponseMetadata, data: Data, id transactionID: UUID)

    /**
     Called after the payload has been extracted from the raw binary data
     contained in the HTTP response body.
     
     This function is called before the payload is validated.

     - parameter payload: The `ResponseDataType` payload extracted from the
     response.

     - parameter transaction: The `HTTPTransaction` being reported to the
     tracer.

     - parameter meta: An `HTTPResponseMetadata` instance containing details
     about the HTTP response.

     - parameter transactionID: A unique identifier for this particular
     execution of `transaction`. As `transaction` executes a single time,
     the `transactionID` can be used to correlate different calls to the
     tracer.
     */
    func didExtract<T>(payload: HTTPTransaction<T>.ResponseDataType, for transaction: HTTPTransaction<T>, meta: HTTPResponseMetadata, id transactionID: UUID)

    /**
     Called after the response payload has been successfully validated.
     
     Payload validation is the last step performed by a successful transaction, 
     so a call to this function ensures there will be a subsequent call to
     `didComplete(transaction:result:meta:id:)` with a `.succeeded`
     `Result`.

     - parameter payload: The validated `ResponseDataType` payload.

     - parameter transaction: The `HTTPTransaction` being reported to the
     tracer.

     - parameter meta: An `HTTPResponseMetadata` instance containing details
     about the HTTP response.

     - parameter transactionID: A unique identifier for this particular
     execution of `transaction`. As `transaction` executes a single time,
     the `transactionID` can be used to correlate different calls to the
     tracer.
     */
    func didValidate<T>(payload: HTTPTransaction<T>.ResponseDataType, for transaction: HTTPTransaction<T>, meta: HTTPResponseMetadata, id transactionID: UUID)

    /**
     Called immediately before an executing transaction reports a final
     `Result` to its `Callback` function.

     This function will be eventually be called for every call to 
     `willExecute(transaction:id:)` having the same `transactionID`.

     - parameter payload: The validated `ResponseDataType` payload.

     - parameter transaction: The `HTTPTransaction` being reported to the
     tracer.

     - parameter meta: An `HTTPResponseMetadata` instance containing details
     about the HTTP response. Will be `nil` if transaction execution did
     not get as far as receiving an HTTP response.

     - parameter transactionID: A unique identifier for this particular
     execution of `transaction`. As `transaction` executes a single time,
     the `transactionID` can be used to correlate different calls to the
     tracer.
     */
    func didComplete<T>(transaction: HTTPTransaction<T>, result: HTTPTransaction<T>.TransactionResult, meta: HTTPResponseMetadata?, id transactionID: UUID)
}
