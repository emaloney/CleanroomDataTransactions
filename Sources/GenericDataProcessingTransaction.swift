//
//  GenericDataProcessingTransaction.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 1/28/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 A `WrappingDataTransaction` that uses a `DataProcessingFunction` to convert 
 the `DataType` of the wrapped `DataTransaction` into type `T`.
 */
public class GenericDataProcessingTransaction<T>: WrappingDataTransaction
{
    public typealias DataType = T
    public typealias MetadataType = WrappedTransactionType.MetadataType
    public typealias Result = TransactionResult<DataType, MetadataType>
    public typealias Callback = (Result) -> Void
    public typealias WrappedTransactionType = URLTransaction
    public typealias DataProcessingFunction = (WrappedTransactionType.DataType) throws -> DataType

    /** The URL of the wrapped `DataTransaction`. */
    public var url: URL { return _wrappedTransaction.url as URL }

    /**  The `DataProcessingFunction` that will be used to produce the
     receiver's `DataType` upon successful completion of the wrapped
     transaction. */
    public let processData: DataProcessingFunction

    /** The underlying transaction used by a `WrappingDataTransaction` for
     lower-level processing. */
    public var wrappedTransaction: WrappedTransactionType? {
        return _wrappedTransaction
    }
    private let _wrappedTransaction: WrappedTransactionType

    private let queueProvider: QueueProvider

    /**
     Initializes a new instance that wraps the given `WrappedTransactionType`
     and uses the specified `DataProcessingFunction` to produce the appropriate
     `DataType`.
     
     - parameter wrapping: The data transaction that will be wrapped by the
     instance being initialized.
     
     - parameter dataProcessor: The `DataProcessingFunction` that will be used
     to produce the `DataType`.

     - parameter queueProvider: Used to supply a GCD queue for asynchronous
     operations when needed.
     */
    public init(wrapping: WrappedTransactionType, dataProcessor: DataProcessingFunction, queueProvider: QueueProvider = DefaultQueueProvider.instance)
    {
        _wrappedTransaction = wrapping
        processData = dataProcessor
        self.queueProvider = queueProvider
    }

    /**
     Causes the transaction to be executed. The transaction may be performed
     asynchronously. When complete, the `Result` is reported to the `Callback`
     function.

     - parameter completion: A function that will be called upon completion
     of the transaction.
     */
    public func executeTransaction(completion: Callback)
    {
        let queue = queueProvider.queue

        _wrappedTransaction.executeTransaction() { result in
            switch result {
            case .succeeded(let data, let meta):
                queue.async {
                    do {
                        let processed = try self.processData(data)
                        completion(.succeeded(processed, meta))
                    }
                    catch {
                        completion(.failed(.wrap(error)))
                    }
                }

            case .failed(let error):
                completion(.failed(error))
            }
        }
    }
}
