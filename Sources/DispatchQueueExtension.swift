//
//  DispatchQueueExtension.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 4/12/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

import Dispatch

extension DispatchQueue
{
    /**
     The `DispatchQueue` used for transaction processing by default when no
     other queue is explicitly specified.
     */
    public static var transactionProcessing: DispatchQueue {
        return TransactionProcessingQueue.instance.queue
    }
}

fileprivate struct TransactionProcessingQueue
{
    fileprivate static var instance = TransactionProcessingQueue()

    fileprivate let queue: DispatchQueue

    private init()
    {
        queue = DispatchQueue(label: String(describing: type(of: TransactionProcessingQueue.self)), attributes: .concurrent)
    }
}
