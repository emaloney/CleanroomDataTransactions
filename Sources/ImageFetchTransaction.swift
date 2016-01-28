//
//  ImageFetchTransaction.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 8/21/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation
import UIKit
import CleanroomConcurrency
import CleanroomLogger

public class ImageFetchTransaction: DelegatingDataTransaction
{
    public typealias DataType = UIImage
    public typealias MetadataType = DelegateTransactionType.MetadataType
    public typealias Result = TransactionResult<DataType, MetadataType>
    public typealias Callback = (Result) -> Void
//#if OFFLINE_MODE
//    public typealias DelegateTransactionType = OfflineURLTransaction
//#else
    public typealias DelegateTransactionType = URLTransaction
//#endif

    public var url: NSURL { return innerTransaction.url }

    public var delegateTransaction: DelegateTransactionType? { return innerTransaction }
    private let innerTransaction: DelegateTransactionType

    public init(url: NSURL)
    {
        innerTransaction = DelegateTransactionType(url: url)
    }

    public func executeTransaction(completion: Callback)
    {
        Log.verbose?.trace()

        innerTransaction.executeTransaction() { result in
            switch result {
            case .Succeeded(let data, let meta):
                async {
                    let image = UIImage(data: data)

                    if image != nil {
                        completion(.Succeeded(image!, meta))
                    } else {
                        completion(.Failed(.DataFormatError("Couldn't construct UIImage instance from the data")))
                    }
                }

            case .Failed(let error):
                completion(.Failed(error))
            }
        }
    }
}
