//
//  URLTransaction.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 7/28/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 A `DataTransaction` that uses an `NSURLRequest` to request data from
 (and potentially send data to) a service at a given URL.
 
 A successful transaction produces an `NSData` instance, and if the request
 was sent via HTTP or HTTPS, the transaction metadata will contain an
 `HTTPResponseMetadata` instance.
 */
public class URLTransaction: DataTransaction
{
    public typealias DataType = NSData
    public typealias MetadataType = HTTPResponseMetadata
    public typealias Result = TransactionResult<DataType, MetadataType>
    public typealias Callback = (Result) -> Void

    /** The URL of the network service that will be sent the request when
     the transaction is executed. */
    public var url: NSURL { return request.URL! }

    /** The `NSURLRequest` that will be issued when the transaction is 
     executed. */
    public let request: NSURLRequest

    /** Optional data to send to the service when executing the
     transaction. */
    public let uploadData: NSData?

    /** The `NSURLSessionConfiguration` used to create the `NSURLSession`
     for the transaction's request. */
    public let sessionConfiguration: NSURLSessionConfiguration

    private var task: NSURLSessionTask?

    /** 
     Initializes a new transaction that will connect to the given URL.
     
     - parameter url: The URL of the network service.
     
     - parameter uploadData: Optional data to send to the network service.
     
     - parameter sessionConfiguration: The `NSURLSessionConfiguration` used to 
     create the `NSURLSession` for the transaction's request.
     */
    public init(url: NSURL, uploadData: NSData? = nil, sessionConfiguration: NSURLSessionConfiguration = .defaultSessionConfiguration())
    {
        self.request = NSURLRequest(URL: url)
        self.uploadData = uploadData
        self.sessionConfiguration = sessionConfiguration
    }

    /**
     Initializes a new transaction that will send to the given request.

     - parameter request: The request to send to the network service.

     - parameter uploadData: Optional data to send to the network service.

     - parameter sessionConfiguration: The `NSURLSessionConfiguration` used to
     create the `NSURLSession` for the transaction's request.
     */
    public init(request: NSURLRequest, uploadData: NSData? = nil, sessionConfiguration: NSURLSessionConfiguration = .defaultSessionConfiguration())
    {
        precondition(request.URL != nil)

        self.request = request
        self.uploadData = uploadData
        self.sessionConfiguration = sessionConfiguration
    }

    deinit {
        if let task = task {
            task.cancel()
        }
    }

    /**
     Causes the transaction to be executed. The transaction may be performed
     asynchronously. When complete, the `Result` is reported to the `Callback`
     function.
     
     - parameter completion: A function that will be called upon completion
     of the transaction.
     */
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

