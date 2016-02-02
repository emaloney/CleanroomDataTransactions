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
    public var url: NSURL { return wrappedTransaction.url }

    /**  The `DataProcessingFunction` that will be used to produce the
     receiver's `DataType` upon successful completion of the wrapped
     transaction. */
    public let processData: DataProcessingFunction

    private let wrappedTransaction: WrappedTransactionType

    /**
     Initializes a new instance that wraps the given `WrappedTransactionType`
     and uses the specified `DataProcessingFunction` to produce the appropriate
     `DataType`.
     
     - parameter wrapping: The data transaction that will be wrapped by the
     instance being initialized.
     
     - parameter dataProcessor: The `DataProcessingFunction` that will be used
     to produce the `DataType`.
     */
    public init(wrapping: WrappedTransactionType, dataProcessor: DataProcessingFunction)
    {
        wrappedTransaction = wrapping
        processData = dataProcessor
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
        wrappedTransaction.executeTransaction() { result in
            switch result {
            case .Succeeded(let data, let meta):
                async {
                    do {
                        let processed = try self.processData(data)
                        completion(.Succeeded(processed, meta))
                    }
                    catch {
                        completion(.Failed(.wrap(error)))
                    }
                }

            case .Failed(let error):
                completion(.Failed(error))
            }
        }
    }
}
