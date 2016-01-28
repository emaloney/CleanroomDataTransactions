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
 data from the given URL.
 
 - note: `PlatformImageType` represents the image type appropriate for the
 runtime platform. On iOS and tvOS, it maps to `UIImage`; on Mac OS X, it's
 `NSImage`.
 */
public class FetchImageTransaction: GenericDataProcessingTransaction<PlatformImageType>
{
    /**
     Initializes a `FetchImageTransaction` to retrieve image data from the 
     specified URL.
     
     - parameter url: The URL from which to fetch image data.
     */
    public init(url: NSURL)
    {
        super.init(wrapping: URLTransaction(url: url), dataProcessor: platformImageFromData)
    }
}
