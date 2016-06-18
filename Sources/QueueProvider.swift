//
//  QueueProvider.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 2/2/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 Certain `DataTransaction`s perform asynchronous operations using Grand Central
 Dispatch. Such `DataTransaction`s will typically be given a `QueueProvider`
 at instantiation to supply a `DispatchQueue` when needed.
 
 By supplying a `QueueProvider` rather than a specific queue, reusable
 `DataTransaction`s can be supplied with different queues over time.
 */
public protocol QueueProvider
{
    /** Returns a `DispatchQueue` to be used for asynchronous operations. */
    var queue: DispatchQueue { get }
}
