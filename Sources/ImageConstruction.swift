//
//  ImageConstruction.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 1/28/16.
//  Copyright © 2016 Gilt Groupe. All rights reserved.
//

import Foundation

#if os(iOS) || os(tvOS)
import UIKit

/** Represents the image type appropriate for the runtime platform. On iOS and
 tvOS, `PlatformImageType` is `UIImage`; on Mac OS X, it is `NSImage`. */
public typealias PlatformImageType = UIImage
#endif

#if os(OSX)
import AppKit

/** Represents the image type appropriate for the runtime platform. On iOS and
 tvOS, `PlatformImageType` is `UIImage`; on Mac OS X, it is `NSImage`. */
public typealias PlatformImageType = NSImage
#endif

/**
 Attempts to convert an `NSData` instance into an image object appropriate for
 the current platform. Used by the `FetchImageTransaction` to construct images
 from transaction data.
 
 - parameter data: The data to convert into an image.
 
 - returns: A `PlatformImageType` instance containing the image.
 
 - throws: A `DataTransactionError` if `data` could not be converted into a
 `PlatformImageType`.
 */
public func platformImageFromData(data: NSData)
    throws
    -> PlatformImageType
{
    guard let image = PlatformImageType(data: data) else {
        throw DataTransactionError.DataFormatError("Couldn't construct \(PlatformImageType.self) from data containing \(data.length) bytes")
    }
    return image
}
