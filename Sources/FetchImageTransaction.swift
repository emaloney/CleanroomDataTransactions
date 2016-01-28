//
//  FetchImageTransaction.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 8/21/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

public typealias FetchImageTransaction = _FetchImageTransaction<PlatformImageType>

public class _FetchImageTransaction<T>: GenericDataProcessingTransaction<PlatformImageType>
{
    public init(url: NSURL)
    {
        super.init(wrapping: URLTransaction(url: url), dataProcessor: platformImageFromData)
    }
}
