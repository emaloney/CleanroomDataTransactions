//
//  GenericDataProcessingTransaction.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 1/28/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation
import CleanroomConcurrency

/**
 A `DataTransaction` that uses a `DataProcessingFunction` 
 */
public class GenericDataProcessingTransaction<T>: WrappingDataTransaction
{
    public typealias DataType = T
    public typealias MetadataType = WrappedTransactionType.MetadataType
    public typealias Result = TransactionResult<DataType, MetadataType>
    public typealias Callback = (Result) -> Void
    public typealias WrappedTransactionType = URLTransaction
    public typealias DataProcessingFunction = (WrappedTransactionType.DataType) throws -> DataType

    public var url: NSURL { return wrappedTransaction.url }
    public let processData: DataProcessingFunction

    private let wrappedTransaction: WrappedTransactionType

    public init(wrapping: WrappedTransactionType, dataProcessor: DataProcessingFunction)
    {
        wrappedTransaction = wrapping
        processData = dataProcessor
    }

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
