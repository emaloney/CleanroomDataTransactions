//
//  DefaultQueueProvider.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 2/2/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 A default `QueueProvider` implementation that always supplies the same
 concurrent `dispatch_queue_t` throughout the lifetime of the running 
 executable.
 */
public struct DefaultQueueProvider: QueueProvider
{
    /** Returns the singleton *(gasp!)* instance of the 
     `DefaultQueueProvider`. */
    public static let instance = DefaultQueueProvider()

    /** Returns a `dispatch_queue_t` to be used for asynchronous operations. */
    public var queue: dispatch_queue_t

    private init()
    {
        queue = dispatch_queue_create("CleanroomDataTransactions.DefaultQueueProvider", DISPATCH_QUEUE_CONCURRENT)
    }
}