//
//  URLTransaction.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 7/28/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation
import CleanroomLogger

public class URLTransaction: DataTransaction
{
    public typealias DataType = NSData
    public typealias MetadataType = HTTPResponseMetadata
    public typealias Result = TransactionResult<DataType, MetadataType>
    public typealias Callback = (Result) -> Void

    public var url: NSURL {
        return request.URL!
    }

    public let request: NSURLRequest
    public let uploadData: NSData?
    public let sessionConfiguration: NSURLSessionConfiguration

    private var task: NSURLSessionTask?

    public convenience init(url: NSURL, uploadData: NSData? = nil)
    {
        self.init(request: NSURLRequest(URL: url), uploadData: uploadData)
    }

    public init(request: NSURLRequest, uploadData: NSData? = nil, sessionConfiguration: NSURLSessionConfiguration = .defaultSessionConfiguration())
    {
        precondition(request.URL != nil)

        self.request = request
        self.uploadData = uploadData
        self.sessionConfiguration = sessionConfiguration
    }

    deinit {
        if let task = task {
            Log.verbose?.message("URLTransaction deallocating with an outstanding NSURLSessionTask for URL <\(task.originalRequest?.URL)>; will cancel it")

            task.cancel()
        }
    }

    public func executeTransaction(completion: Callback)
    {
        guard task == nil else {
            completion(.Failed(.AlreadyInFlight))
            return
        }
        
        // create a delegate-free session & fire the request
        let session = NSURLSession(configuration: sessionConfiguration)

        let handler: (NSData?, NSURLResponse?, NSError?) -> Void = { [weak self] data, response, error in
            guard let strongSelf = self else {
                completion(.Failed(.Canceled))
                return
            }

            strongSelf.task = nil

            guard error == nil else {
                completion(.Failed(.wrap(error!)))
                return
            }

            guard let data = data else {
                completion(.Failed(.NoData))
                return
            }

            guard let httpResp = response as? NSHTTPURLResponse else {
                completion(.Failed(.HTTPRequired))
                return
            }

            let meta = HTTPResponseMetadata(url: httpResp.URL ?? strongSelf.url, responseStatusCode: httpResp.statusCode, mimeType: httpResp.MIMEType, textEncoding: httpResp.textEncodingName, httpHeaders: httpResp.allHeaderFields)

            completion(.Succeeded(data, meta))
        }

        if let uploadData = uploadData {
            task = session.uploadTaskWithRequest(request, fromData: uploadData, completionHandler: handler)
        } else {
            task = session.dataTaskWithRequest(request, completionHandler: handler)
        }

        guard let task = task else {
            completion(.Failed(.SessionTaskNotCreated))
            return
        }

        task.resume()   // this kicks off the HTTP request
    }
}

