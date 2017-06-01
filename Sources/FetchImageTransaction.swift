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
open class FetchImageTransaction: HTTPTransaction<PlatformImageType>
{
    /**
     Initializes a `FetchImageTransaction` to retrieve image data from the 
     specified URL.
     
     - parameter url: The URL of the image.
     */
    public init(url: URL, processingQueue: DispatchQueue = .transactionProcessing)
    {
        super.init(url: url, transactionType: .media, processingQueue: processingQueue)

        processPayload = { _, data, _ in
            return try platformImage(fromData: data)
        }
    }
}
