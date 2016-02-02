//
//  QueueAsyncFunctionExtension.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 2/2/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

extension dispatch_queue_t
{
    internal func async(fn: () -> Void)
    {
        dispatch_async(self) {
            fn()
        }
    }
}
