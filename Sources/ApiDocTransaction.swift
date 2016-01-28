//
//  ApiDocTransaction.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 7/28/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

public class ApiDocTransaction<T>: JSONTransaction<T>
{
    public override init(request: NSURLRequest, uploadData: NSData? = nil)
    {
        super.init(request: request, uploadData: uploadData)

        metadataProcessingFunction = httpRequiredStatusCodeHandler
    }

    public override init(url: NSURL, uploadData: NSData? = nil)
    {
        super.init(url: url, uploadData: uploadData)

        metadataProcessingFunction = httpRequiredStatusCodeHandler
    }
}

public typealias ApiDocDictionaryTransaction = ApiDocTransaction<NSDictionary>

public typealias ApiDocArrayTransaction = ApiDocTransaction<NSArray>

public class ApiDocOptionalTransaction<T>: JSONOptionalTransaction<T>
{
    public override init(request: NSURLRequest, uploadData: NSData? = nil)
    {
        super.init(request: request, uploadData: uploadData)

        payloadProcessingFunction = optionalPayloadProcessor
        metadataProcessingFunction = httpRequiredStatusCodeHandler
    }

    public override init(url: NSURL, uploadData: NSData? = nil)
    {
        super.init(url: url, uploadData: uploadData)

        payloadProcessingFunction = optionalPayloadProcessor
        metadataProcessingFunction = httpRequiredStatusCodeHandler
    }
}

public typealias ApiDocOptionalDictionaryTransaction = ApiDocOptionalTransaction<NSDictionary>

public typealias ApiDocOptionalArrayTransaction = ApiDocOptionalTransaction<NSArray>
