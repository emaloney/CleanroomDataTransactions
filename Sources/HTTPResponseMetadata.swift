//
//  HTTPResponseMetadata.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 9/25/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 The `MetadataType` for `DataTransaction`s that communicate via HTTP and HTTPS.
 */
public struct HTTPResponseMetadata
{
    /** The `NSURL` of the originating HTTP request. */
    public let url: URL

    /** The status code of the HTTP response. */
    public let responseStatusCode: Int

    /** The MIME type of the HTTP response body, if any. */
    public let mimeType: String?

    /** The text encoding of the HTTP response body, if any. */
    public let textEncoding: String?

    /** The HTTP response header fields. */
    public let httpHeaders: [String: AnyObject]

    public init(url: URL, responseStatusCode: Int, mimeType: String?, textEncoding: String?, httpHeaders: [NSObject: AnyObject])
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
    /** The `HTTPResponseStatus` of the receiver. */
    public var responseStatus: HTTPResponseStatus {
        return HTTPResponseStatus(responseStatusCode)
    }
}
