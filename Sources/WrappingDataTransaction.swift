//
//  WrappingDataTransaction.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 1/28/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

/**
 Represents a `DataTransaction` that wraps another `DataTransaction` of
 a potentially different type.
 
 When a `WrappingDataTransaction` is executed, it may also execute the
 wrapped `DataTransaction` in order to perform some of its work.
 */
public protocol WrappingDataTransaction: DataTransaction
{
    /** The `DataTransaction` type to which a `WrappingDataTransaction` may
     delegate some of its work. */
    associatedtype WrappedTransactionType: DataTransaction

    /** The underlying transaction used by a `WrappingDataTransaction` for
     lower-level processing. */
    var wrappedTransaction: WrappedTransactionType? { get }
}
