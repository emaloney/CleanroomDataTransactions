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
 concurrent `DispatchQueue` throughout the lifetime of the running 
 executable.
 */
public struct DefaultQueueProvider: QueueProvider
{
    /** Returns the singleton *(gasp!)* instance of the 
     `DefaultQueueProvider`. */
    public static let instance = DefaultQueueProvider()

    /** Returns a `DispatchQueue` to be used for asynchronous operations. */
    public var queue: DispatchQueue

    private init()
    {
        queue = DispatchQueue(label: "CleanroomDataTransactions.DefaultQueueProvider", attributes: DispatchQueueAttributes.concurrent)
    }
}
