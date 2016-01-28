//
//  DataTransaction.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 7/21/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

public enum TransactionResult<DataType, MetadataType>
{
    case Succeeded(DataType, MetadataType)
    case Failed(DataTransactionError)
}

public protocol DataTransaction
{
    typealias DataType
    typealias MetadataType
    typealias Result = TransactionResult<DataType, MetadataType>
    typealias Callback = (Result) -> Void
    typealias CacheStorageHook = (Self, data: DataType, metadata: MetadataType) -> Void

    func executeTransaction(completion: Callback)
}

public protocol DelegatingDataTransaction: DataTransaction
{
    typealias DelegateTransactionType: DataTransaction

    var delegateTransaction: DelegateTransactionType? { get }
}