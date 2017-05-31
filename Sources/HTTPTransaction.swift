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
 (and potentially send data to) an HTTP-based service.
 
 A successful transaction produces an `Data` instance, and if the request
 was sent via HTTP or HTTPS, the transaction metadata will contain an
 `HTTPResponseMetadata` instance.
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
    public typealias PayloadProcessor = (HTTPTransaction<T>, Data, HTTPResponseMetadata) throws -> T

    /** If the payload processor succeeds, the results are passed to the
     payload validator, giving the transaction one final chance to sanity-check
     the data and bail if there's a problem. */
    public typealias PayloadValidator = (HTTPTransaction<T>, T, Data, HTTPResponseMetadata) throws -> Void

    /** Indicates the type of transaction provided by the implementation. */
    public enum TransactionType {
        /** The transaction interacts with an API endpoint. */
        case api

        /** The transaction interacts with a media server. */
        case media
    }

    /** The protocol scheme used by the service. */
    public let scheme: String

    /** The hostname of the service. */
    public let host: String

    /** The path portion of the service URL. */
    public let urlPath: String

    /** Optional data to send to the service when executing the
     transaction. */
    public let uploadData: Data?

    /** Indicates the type of transaction provided by the receiver. */
    public let transactionType: TransactionType

    /** A function called to construct the `URL` used for the transaction.
     The default implementation constructs the `URL` using the `scheme`,
     `host` and `urlPath` of the transaction. */
    public var constructURL: URLConstructor = { txn in
        let urlStr = "\(txn.scheme)://\(txn.host)\(txn.urlPath)"
        guard let url = URL(string: urlStr) else {
            throw DataTransactionError.invalidURL(urlStr)
        }
        return url
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
        guard let payload = data as? T else {
            throw DataTransactionError.dataFormatError("Expected payload to be \(T.self) for a \(type(of: txn)) transaction (targeting \(txn.urlPath)); got a \(type(of: data)) instead.")
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
     
     - parameter scheme: The protocol scheme used to communicate with
     the service.

     - parameter host: The hostname of the service.

     - parameter urlPath: The path portion of the URL at which the network
     service is hosted. If non-empty, this string _must_ begin with a slash
     ("`/`") character.
     
     - parameter transactionType: Specifies the transaction type.
     
     - parameter data: Optional data to send to the network service.
     
     - parameter queue: A `DispatchQueue` to use for processing transaction
     responses.
     */
    public init(scheme: String = NSURLProtectionSpaceHTTPS, host: String, urlPath: String, transactionType: TransactionType = .api, upload data: Data? = nil, processingQueue queue: DispatchQueue = .transactionProcessing)
    {
        self.scheme = scheme
        self.host = host
        self.urlPath = urlPath
        self.transactionType = transactionType
        self.uploadData = data
        self.processingQueue = queue
    }

    deinit {
        task?.cancel()
    }

    public func cancel()
    {
        task?.cancel()
        task = nil
        pinnedTransaction = nil
    }

    private func call(_ completion: @escaping Callback, with result: Result)
    {
        completion(result)

        task = nil
        pinnedTransaction = nil
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
        do {
            guard task == nil else {
                throw DataTransactionError.alreadyInFlight
            }

            pinnedTransaction = self
            
            // create and configure the request
            let url = try constructURL(self)
            var req = try constructRequest(self, url)
            try configureRequest(self, &req)

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
