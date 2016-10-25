//
//  URLTransaction.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 7/28/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 A `DataTransaction` that uses an `URLRequest` to request data from
 (and potentially send data to) a service at a given URL.
 
 A successful transaction produces an `Data` instance, and if the request
 was sent via HTTP or HTTPS, the transaction metadata will contain an
 `HTTPResponseMetadata` instance.
 */
open class URLTransaction: DataTransaction
{
    public typealias DataType = Data
    public typealias MetadataType = HTTPResponseMetadata
    public typealias Result = TransactionResult<DataType, MetadataType>
    public typealias Callback = (Result) -> Void

    /** The URL of the network service that will be sent the request when
     the transaction is executed. */
    public var url: URL { return request.url! }

    /** The `URLRequest` that will be issued when the transaction is 
     executed. */
    public let request: URLRequest

    /** Optional data to send to the service when executing the
     transaction. */
    public let uploadData: Data?

    /** The `URLSessionConfiguration` used to create the `URLSession`
     for the transaction's request. */
    public let sessionConfiguration: URLSessionConfiguration

    private var task: URLSessionTask?

    /** 
     Initializes a new transaction that will connect to the given URL.
     
     - parameter url: The URL of the network service.
     
     - parameter data: Optional data to send to the network service.
     
     - parameter sessionConfiguration: The `URLSessionConfiguration` used to
     create the `URLSession` for the transaction's request.
     */
    public init(url: URL, upload data: Data? = nil, sessionConfiguration: URLSessionConfiguration = .default)
    {
        self.request = URLRequest(url: url)
        self.uploadData = data
        self.sessionConfiguration = sessionConfiguration
    }

    /**
     Initializes a new transaction that will send to the given request.

     - parameter request: The request to send to the network service.

     - parameter data: Optional data to send to the network service.

     - parameter sessionConfiguration: The `URLSessionConfiguration` used to
     create the `URLSession` for the transaction's request.
     */
    public init(request: URLRequest, upload data: Data? = nil, sessionConfiguration: URLSessionConfiguration = .default)
    {
        precondition(request.url != nil)

        self.request = request
        self.uploadData = data
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
    open func executeTransaction(completion: @escaping Callback)
    {
        guard task == nil else {
            completion(.failed(.alreadyInFlight))
            return
        }
        
        // create a delegate-free session & fire the request
        let session = URLSession(configuration: sessionConfiguration)

        let handler: (Data?, URLResponse?, Error?) -> Void = { [weak self] data, response, error in
            guard let strongSelf = self else {
                completion(.failed(.canceled))
                return
            }

            strongSelf.task = nil

            guard error == nil else {
                completion(.failed(.wrap(error!)))
                return
            }

            guard let data = data else {
                completion(.failed(.noData))
                return
            }

            guard let httpResp = response as? HTTPURLResponse else {
                completion(.failed(.httpRequired))
                return
            }

            let meta = HTTPResponseMetadata(url: httpResp.url ?? strongSelf.url, responseStatusCode: httpResp.statusCode, mimeType: httpResp.mimeType, textEncoding: httpResp.textEncodingName, httpHeaders: httpResp.allHeaderFields as! [String: String])

            completion(.succeeded(data, meta))
        }

        if let uploadData = uploadData {
            task = session.uploadTask(with: request, from: uploadData, completionHandler: handler)
        } else {
            task = session.dataTask(with: request, completionHandler: handler)
        }

        guard let task = task else {
            completion(.failed(.sessionTaskNotCreated))
            return
        }

        task.resume()   // this kicks off the HTTP request
    }
}

