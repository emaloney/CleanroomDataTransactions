//
//  HTTPResponseMetadata.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 9/25/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation
import CleanroomConcurrency
//import CleanroomDateTime
import CleanroomLogger

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


//
// DISABLING -- this is the only line of code that requires CleanroomDateTime;
//              in order to minimize unneeded dependencies, we're going to move
//              it to AppleTart     --ECM 1/28/2016
//
//extension HTTPResponseMetadata
//{
//    public var serverTime: NSDate? {
//        return (httpHeaders["Date"] as? String)?.asDateRFC1123()
//    }
//}