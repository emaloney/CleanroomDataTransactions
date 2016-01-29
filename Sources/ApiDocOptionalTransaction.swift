//
//  ApiDocOptionalTransaction.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 7/28/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

public class ApiDocOptionalTransaction<T>: JSONOptionalTransaction<T>
{
    public override init(request: NSURLRequest, uploadData: NSData? = nil)
    {
        super.init(request: request, uploadData: uploadData)

        validateMetadata = httpRequiredStatusCodeValidator
        processPayload = optionalPayloadProcessor
    }

    public override init(url: NSURL, uploadData: NSData? = nil)
    {
        super.init(url: url, uploadData: uploadData)

        validateMetadata = httpRequiredStatusCodeValidator
        processPayload = optionalPayloadProcessor
    }
}

public typealias ApiDocOptionalDictionaryTransaction = ApiDocOptionalTransaction<NSDictionary>

public typealias ApiDocOptionalArrayTransaction = ApiDocOptionalTransaction<NSArray>
