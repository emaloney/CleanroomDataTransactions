//
//  HTTPResponseMetadata.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 9/25/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

public struct HTTPResponseMetadata
{
    public let url: NSURL
    public let responseStatusCode: Int
    public let mimeType: String?
    public let textEncoding: String?
    public let httpHeaders: [String: AnyObject]

    public init(url: NSURL, responseStatusCode: Int, mimeType: String?, textEncoding: String?, httpHeaders: [NSObject: AnyObject])
    {
        self.url = url
        self.responseStatusCode = responseStatusCode
        self.mimeType = mimeType
        self.textEncoding = textEncoding
        self.httpHeaders = httpHeaders as! [String: AnyObject]
    }
}

extension HTTPResponseMetadata
{
    public var responseStatus: HTTPResponseStatus {
        return HTTPResponseStatus(responseStatusCode)
    }
}
