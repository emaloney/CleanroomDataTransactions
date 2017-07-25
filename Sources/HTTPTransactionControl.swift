//
//  HTTPTransactionControl.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 7/25/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 Settings controlling the behavior of `HTTPTransaction`s.
 */
public struct HTTPTransactionControl
{
    /** An `HTTPTransactionConfigurator` used to configure _all_
     `HTTPTransaction`s. */
    public static var configurator: HTTPTransactionConfigurator?

    /** An `HTTPTransactionTracer` that can be used to trace the execution
     of _all_ `HTTPTransaction`s from beginning to end. */
    public static var tracer: HTTPTransactionTracer?
}
