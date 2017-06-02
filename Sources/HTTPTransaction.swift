//
//  URLTransaction.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 7/28/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 A `DataTransaction` that uses a `URLRequest` to request data from
 (and potentially send data to) an HTTP(S)-based service.
 
 A successful transaction produces an instance of type `T` (also known herein
 as `DataType` via conformance to the `DataTransaction` protocol).
 */
open class HTTPTransaction<T>: DataTransaction
{
    public typealias DataType = T
    public typealias MetadataType = HTTPResponseMetadata

    /** The signature of a function used to construct `URL` instances for 
     the transaction. */
    public typealias URLConstructor = (HTTPTransaction<T>) throws -> URL

    /** The signature of a function used to construct `URLRequest`s for
     the transaction. */
    public typealias RequestConstructor = (HTTPTransaction<T>, URL) throws -> URLRequest

    /** The signature of a function used to configure the `URLRequest` prior to
     issuing the transaction. */
    public typealias RequestConfigurator = (HTTPTransaction<T>, inout URLRequest) throws -> Void

    /** The signature of a function used to validate the response received
     by an HTTP transaction. */
    public typealias ResponseValidator = (HTTPTransaction<T>, HTTPURLResponse, HTTPResponseMetadata, Data) throws -> Void

    /** The signature of a payload processing function. This function accepts
     binary `Data` and attempts to convert it to `DataType`. */
    public typealias PayloadProcessor = (HTTPTransaction<T>, Data, HTTPResponseMetadata) throws -> DataType

    /** If the payload processor succeeds, the results are passed to the
     payload validator, giving the transaction one final chance to sanity-check
     the data and bail if there's a problem. */
    public typealias PayloadValidator = (HTTPTransaction<T>, DataType, Data, HTTPResponseMetadata) throws -> Void

    /** Indicates the type of transaction provided by the implementation. */
    public enum TransactionType {
        /** The transaction interacts with an API endpoint. */
        case api

        /** The transaction interacts with a media server. */
        case media
    }

    /** The URL of the service to be used by the transaction. */
    public let url: URL

    /** The HTTP request method to use for the transaction. */
    public let method: String

    /** Optional data to send to the service when executing the
     transaction. */
    public let uploadData: Data?

    /** The MIME type of the `uploadData` (if any). If present, this value is
     sent as HTTP request's `Content-Type` header. */
    public let mimeType: String?

    /** Indicates the type of transaction provided by the receiver. */
    public let transactionType: TransactionType

    /** A function called to construct the `URL` used for the transaction.
     The default implementation simply returns the value of the transaction's
     `url` property. */
    public var constructURL: URLConstructor = { txn in
        return txn.url
    }

    /** A function called to construct the `URLRequest` used to execute the
     transaction. The default implementation returns a simple `URLRequest`
     constructed from the passed-in `URL`. */
    public var constructRequest: RequestConstructor = { _, url in
        return URLRequest(url: url)
    }

    /** A function called to configure the `URLRequest` prior to executing
     the transaction. The default implementation does nothing. */
    public var configureRequest: RequestConfigurator = { _, _ in }

    /**  The `PayloadProcessor` that will be used to produce the receiver's
     `DataType` upon successful completion of the transaction. */
    public var processPayload: PayloadProcessor = { txn, data, _ in
        guard let payload = data as? DataType else {
            throw DataTransactionError.dataFormatError("Expected payload to be \(DataType.self) for a \(type(of: txn)) transaction (targeting \(txn.url)); got a \(type(of: data)) instead.")
        }
        return payload
    }

    /**  The `PayloadValidator` that will be used to validate the `DataType`
     produced by the `PayloadProcessor` upon successful completion of the
     transaction. */
    public var validatePayload: PayloadValidator = { _, _, _, _ in }

    /** The `URLSessionConfiguration` used to create the `URLSession` for
     the transaction. */
    public var sessionConfiguration: URLSessionConfiguration = .default

    /** A `ResponseValidator` function used to validate the HTTP response 
     received when executing a transaction. */
    public var validateResponse: ResponseValidator = { _, resp, meta, data in
        guard !meta.responseStatus.isError else {
            throw DataTransactionError.httpError(resp, meta, data)
        }
    }

    private var pinnedTransaction: HTTPTransaction<T>?
    private var task: URLSessionTask?
    private let processingQueue: DispatchQueue

    /** 
     Initializes a new transaction that will connect to the given service.
     
     - parameter url: The URL to use for conducting the transaction.

     - parameter method: The HTTP request method. When not explicitly set,
     defaults to "`GET`" unless `data` is non-`nil`, in which case the value
     defaults to "`POST`".

     - parameter data: Optional data to send to the service.

     - parameter mimeType: The MIME type of `data`. If present, this value
     is sent as the `Content-Type` header for the HTTP request.

     - parameter transactionType: Specifies the transaction type.

     - parameter queue: A `DispatchQueue` to use for processing transaction
     responses.
     */
    public init(url: URL, method: String? = nil, upload data: Data? = nil, mimeType: String? = nil, transactionType: TransactionType = .api, processingQueue queue: DispatchQueue = .transactionProcessing)
    {
        var requestMethod = method
        if requestMethod == nil {
            if data == nil {
                requestMethod = "GET"
            } else {
                requestMethod = "POST"
            }
        }

        self.url = url
        self.method = requestMethod!
        self.uploadData = data
        self.mimeType = mimeType
        self.transactionType = transactionType
        self.processingQueue = queue
    }

    deinit {
        task?.cancel()
    }

    open func cancel()
    {
        pinnedTransaction = nil
        task?.cancel()
        task = nil
    }

    private func call(_ completion: @escaping Callback, with result: Result)
    {
        completion(result)

        task = nil
        pinnedTransaction = nil
    }

    /**
     Configures the `URLRequest`.
     
     - note: Subclasses overriding this function should call `super`.
     
     - parameter request: The `URLRequest` to configure.
     */
    open func configure(request: inout URLRequest)
    {
        request.httpMethod = method

        if let mimeType = mimeType {
            request.addValue(mimeType, forHTTPHeaderField: "Content-Type")
        }
    }

    open func executeTransaction(completion: @escaping Callback)
    {
        do {
            guard task == nil else {
                throw DataTransactionError.alreadyInFlight
            }

            pinnedTransaction = self
            
            // create and configure the request
            let url = try constructURL(self)
            var req = try constructRequest(self, url)
            configure(request: &req)            // allow subclasses to configure the request
            try configureRequest(self, &req)    // external users can configure the request via RequestConfigurator function

            // create a delegate-free session & fire the request
            let session = URLSession(configuration: sessionConfiguration)

            let handler: (Data?, URLResponse?, Error?) -> Void = { [weak self, queue = processingQueue] data, response, error in
                queue.async {
                    do {
                        guard let `self` = self else {
                            throw DataTransactionError.canceled
                        }

                        guard error == nil else {
                            throw error!
                        }

                        guard let data = data else {
                            throw DataTransactionError.noData
                        }

                        guard let httpResp = response as? HTTPURLResponse else {
                            throw DataTransactionError.httpRequired
                        }

                        let meta = HTTPResponseMetadata(url: url, responseStatusCode: httpResp.statusCode, mimeType: httpResp.mimeType, textEncoding: httpResp.textEncodingName, httpHeaders: httpResp.allHeaderFields as! [String: String])

                        try self.validateResponse(self, httpResp, meta, data)

                        let payload = try self.processPayload(self, data, meta)
                        try self.validatePayload(self, payload, data, meta)
                        self.call(completion, with: .succeeded(payload, meta))
                    }
                    catch {
                        self?.call(completion, with: .failed(.wrap(error)))
                    }
                }
            }

            if let uploadData = uploadData {
                task = session.uploadTask(with: req, from: uploadData, completionHandler: handler)
            } else {
                task = session.dataTask(with: req, completionHandler: handler)
            }
            
            guard let task = task else {
                throw DataTransactionError.sessionTaskNotCreated
            }
            
            task.resume()   // this kicks off the HTTP request
        }
        catch {
            call(completion, with: .failed(.wrap(error)))
        }
    }
}
