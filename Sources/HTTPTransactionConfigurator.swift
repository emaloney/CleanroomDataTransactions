//
//  HTTPTransactionConfigurator.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 7/25/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 A protocol implemented by entities that wish to configure `HTTPTransaction`s.
 */
public protocol HTTPTransactionConfigurator
{
    /**
     Configures the passed-in `HTTPTransaction`.

     - parameter transaction: The `HTTPTransaction` being configured.
     */
    func configure<T>(transaction: HTTPTransaction<T>)
}
