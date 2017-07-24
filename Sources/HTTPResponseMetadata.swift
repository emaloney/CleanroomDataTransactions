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
    /** The original `URL` before rewriting. */
    public let originalURL: URL

    /** The `URL` used to issue the request, after URL rewriting. */
    public let issuedURL: URL

    /** The final `URL` used to serve the request, after any server-side
     redirects. */
    public let finalURL: URL

    /** The status code of the HTTP response. */
    public let responseStatusCode: Int

    /** The MIME type of the HTTP response body, if any. */
    public let mimeType: String?

    /** The text encoding of the HTTP response body, if any. */
    public let textEncoding: String?

    /** The HTTP response header fields. */
    public let httpHeaders: [String: String]

    /**
     Initializes an `HTTPResponseMetadata` instance.
     
     - parameter originalURL: The original `URL` before any URL rewriting.

     - parameter issuedURL: The `URL` used to issue the request, after URL
     any rewriting.

     - parameter finalURL: The final `URL` used to serve the request, after any
     server-side redirects.

     - parameter responseStatusCode: The status code of the HTTP response.
     
     - parameter mimeType: The MIME type of the HTTP response body, if any.
     
     - parameter textEncoding: The text encoding of the HTTP response body, if 
     any.
     
     - parameter httpHeaders: The HTTP response header fields.
     */
    public init(originalURL: URL, issuedURL: URL, finalURL: URL, responseStatusCode: Int, mimeType: String?, textEncoding: String?, httpHeaders: [String: String])
    {
        self.originalURL = originalURL
        self.issuedURL = issuedURL
        self.finalURL = finalURL
        self.responseStatusCode = responseStatusCode
        self.mimeType = mimeType
        self.textEncoding = textEncoding
        self.httpHeaders = httpHeaders
    }
}

extension HTTPResponseMetadata
{
    /** The `HTTPResponseStatus` of the receiver. */
    public var responseStatus: HTTPResponseStatus {
        return HTTPResponseStatus(responseStatusCode)
    }
}
