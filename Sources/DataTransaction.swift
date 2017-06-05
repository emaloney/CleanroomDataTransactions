//
//  DataTransaction.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 7/21/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

/**
 Represents the possible outcomes of executing a given `DataTransaction`.
 */
public enum TransactionResult<ResponseDataType, MetadataType>
{
    /** Represents the result of a successfully executed transaction.
     The case includes the data and metadata returned by the transaction. */
    case succeeded(ResponseDataType, MetadataType)

    /** Represents the result of a failed executed transaction.
     The case includes a `DataTransactionError` representing the problem. */
    case failed(DataTransactionError)
}

/**
 An interface for an asynchronously-executing data transaction.
 */
public protocol DataTransaction
{
    /** The data type returned by a successful transaction. */
    associatedtype ResponseDataType

    /** The metadata type returned along with a successful transaction. */
    associatedtype MetadataType

    /** The result type passed to the transaction completion callback
     function. */
    typealias Result = TransactionResult<ResponseDataType, MetadataType>

    /** The signature of the callback function passed to
     `executeTransaction()`. */
    typealias Callback = (Result) -> Void

    /**
     Causes the transaction to be executed. The transaction may be performed
     asynchronously. When complete, the `Result` is reported to the `Callback`
     function.
     
     Unless the `cancel()` function is called prior to completion, the
     transaction will remain in memory until the `Callback` is executed.
     
     - parameter completion: A function that will be called upon completion
     of the transaction.
     */
    func executeTransaction(completion: @escaping Callback)

    /**
     Attempts to cancel the transaction prior to completion.
     */
    func cancel()
}
