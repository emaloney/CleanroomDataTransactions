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
 tvOS, `PlatformImageType` is `UIImage`; on macOS, `NSImage`; and on watchOS,
 `WKImage`. */
public typealias PlatformImageType = UIImage
#endif

#if os(macOS)
import AppKit

/** Represents the image type appropriate for the runtime platform. On iOS and
 tvOS, `PlatformImageType` is `UIImage`; on macOS, `NSImage`; and on watchOS,
 `WKImage`. */
public typealias PlatformImageType = NSImage
#endif

#if os(watchOS)
import WatchKit

/** Represents the image type appropriate for the runtime platform. On iOS and
 tvOS, `PlatformImageType` is `UIImage`; on macOS, `NSImage`; and on watchOS,
 `WKImage`. */
public typealias PlatformImageType = WKImage

// compatibility shim
extension WKImage
{
    /**
     A compatibility shim for the `PlatformImageType`; proxies this call
     to `self.init(imageData: data)`.
     
     - parameter data: The image data.
     */
    public convenience init?(data: Data)
    {
        self.init(imageData: data)
    }
}
#endif

/**
 Attempts to convert an `Data` instance into an image object appropriate for
 the current platform. Used by the `FetchImageTransaction` to construct images
 from transaction data.
 
 - parameter data: The data to convert into an image.
 
 - returns: A `PlatformImageType` instance containing the image.
 
 - throws: A `DataTransactionError` if `data` could not be converted into a
 `PlatformImageType`.
 */
public func platformImage(fromData data: Data)
    throws
    -> PlatformImageType
{
    guard let image = PlatformImageType(data: data) else {
        throw DataTransactionError.dataFormatError("Couldn't construct \(PlatformImageType.self) from data containing \(data.count) bytes")
    }
    return image
}
