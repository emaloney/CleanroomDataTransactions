//
//  FetchImageTransaction.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 8/21/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 Attempts to construct a platform-appropriate image object by fetching image
 data from the given service.
 
 - note: `PlatformImageType` represents the image type appropriate for the
 runtime platform. On iOS and tvOS, it maps to `UIImage`; on Mac OS X, it's
 `NSImage`.
 */
open class FetchImageTransaction: GenericPayloadTransaction<PlatformImageType>
{
    /**
     Initializes a `FetchImageTransaction` to retrieve image data from the 
     specified URL.
     
     - parameter scheme: The protocol scheme used to communicate with
     the service.

     - parameter host: The hostname of the service.

     - parameter urlPath: The path portion of the URL at which the network
     service is hosted.

     - parameter queueProvider: Used to supply a GCD queue for asynchronous
     operations when needed.
     */
    public init(scheme: String = NSURLProtectionSpaceHTTPS, host: String, urlPath: String, processingQueue: DispatchQueue = .transactionProcessing)
    {
        super.init(scheme: scheme, host: host, urlPath: urlPath, transactionType: .media, processingQueue: processingQueue) { _, data, _ in
            return try platformImage(fromData: data)
        }
    }
}
