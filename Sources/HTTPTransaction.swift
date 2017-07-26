//
//  HTTPTransaction.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 7/28/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation

/**
 A `DataTransaction` that uses a `URLRequest` to request data from
 (and potentially send data to) an HTTP(S)-based service.
 
 A successful transaction produces an instance of `ResponseDataType`.
 */
open class HTTPTransaction<HTTPResponseDataType>: DataTransaction
{
    public typealias ResponseDataType = HTTPResponseDataType
    public typealias MetadataType = HTTPResponseMetadata

    /** The signature of a function used to construct `URL` instances for 
     the transaction. */
    public typealias URLConstructor = (HTTPTransaction<ResponseDataType>) throws -> URL

    /** The signature of a function used to construct `URLRequest`s for
     the transaction. */
    public typealias RequestConstructor = (HTTPTransaction<ResponseDataType>, URL) throws -> URLRequest

    /** The signature of a function used to configure the `URLRequest` prior to
     issuing the transaction. */
    public typealias RequestConfigurator = (HTTPTransaction<ResponseDataType>, inout URLRequest) throws -> Void

    /** The signature of a function used to validate the response received
     by an HTTP transaction. */
    public typealias ResponseValidator = (HTTPTransaction<ResponseDataType>, HTTPURLResponse, HTTPResponseMetadata, Data) throws -> Void

    /** The signature of a payload processing function. This function accepts
     binary `Data` and attempts to convert it to `ResponseDataType`. */
    public typealias PayloadProcessor = (HTTPTransaction<ResponseDataType>, Data, HTTPResponseMetadata) throws -> ResponseDataType

    /** If the payload processor succeeds, the results are passed to the
     payload validator, giving the transaction one final chance to sanity-check
     the data and bail if there's a problem. */
    public typealias PayloadValidator = (HTTPTransaction<ResponseDataType>, ResponseDataType, Data, HTTPResponseMetadata) throws -> Void

    /** The signature of a function to be called upon successful completion
     of a transaction, to allow cache storage of the transaction response. */
    public typealias CacheStorageHook = (HTTPTransaction<ResponseDataType>, ResponseDataType, HTTPResponseMetadata) -> Void

    /** The `CacheStorageHook` that will be passed the `ResponseDataType` when
     a transaction completes successfully. */
    public var storeInCache: CacheStorageHook?

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
    public let method: HTTPRequestMethod

    /** Optional data to send to the service when executing the
     transaction. */
    public let uploadData: Data?

    /** The MIME type of the `uploadData` (if any). If present, this value is
     sent as HTTP request's `Content-Type` header. */
    public let contentType: MIMEType?

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
     `ResponseDataType` upon successful completion of the transaction. */
    public var processPayload: PayloadProcessor = { txn, data, _ in
        guard let payload = data as? ResponseDataType else {
            throw DataTransactionError.dataFormatError("Expected payload to be \(ResponseDataType.self) for a \(type(of: txn)) transaction (targeting \(txn.url)); got a \(type(of: data)) instead.")
        }
        return payload
    }

    /**  The `PayloadValidator` used to validate the `ResponseDataType`
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

    private var pinnedTransaction: HTTPTransaction<ResponseDataType>?
    private var task: URLSessionTask?
    private let processingQueue: DispatchQueue

    /** 
     Initializes a new transaction that will connect to the given service.
     
     - parameter url: The URL to use for conducting the transaction.

     - parameter method: The HTTP request method. When not explicitly set,
     defaults to `.get` unless `data` is non-`nil`, in which case the value
     defaults to `.post`.

     - parameter data: Optional data to send to the service.

     - parameter mimeType: The MIME type of `data`. If present, this value
     is sent as the `Content-Type` header for the HTTP request.

     - parameter transactionType: Specifies the transaction type.

     - parameter queue: A `DispatchQueue` to use for processing transaction
     responses.
     */
    public init(url: URL, method: HTTPRequestMethod? = nil, upload data: Data? = nil, contentType: MIMEType? = nil, transactionType: TransactionType = .api, processingQueue queue: DispatchQueue = .transactionProcessing)
    {
        self.url = url
        self.method = method ?? ((data == nil) ? .get : .post)
        self.uploadData = data
        self.contentType = contentType
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
        request.httpMethod = method.asString

        if let mimeType = contentType?.rawValue {
            request.addValue(mimeType, forHTTPHeaderField: "Content-Type")
        }
    }

    open func executeTransaction(completion: @escaping Callback)
    {
        let tracer = HTTPTransactionControl.tracer
        let txnID = UUID()

        tracer?.willExecute(transaction: self, id: txnID)

        do {
            guard task == nil else {
                throw DataTransactionError.alreadyInFlight
            }

            pinnedTransaction = self

            // configure ourselves
            if let txnConfig = HTTPTransactionControl.configurator {
                txnConfig.configure(transaction: self)
            }

            // create and configure the request
            let url = try constructURL(self)
            var req = try constructRequest(self, url)
            configure(request: &req)            // allow subclasses to configure the request
            try configureRequest(self, &req)    // external users can configure the request via RequestConfigurator function

            guard let issuedURL = req.url else {
                throw DataTransactionError.noURL
            }

            tracer?.didConfigure(request: req, for: self, id: txnID)

            // create a delegate-free session & fire the request
            let session = URLSession(configuration: sessionConfiguration)

            let handler: (Data?, URLResponse?, Error?) -> Void = { [weak self, queue = processingQueue] data, response, error in
                queue.async {
                    var respMeta: HTTPResponseMetadata?     // for the transactionCompleted in the catch block
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

                        let finalURL = httpResp.url ?? issuedURL
                        let meta = HTTPResponseMetadata(originalURL: url, issuedURL: issuedURL, finalURL: finalURL, responseStatusCode: httpResp.statusCode, mimeType: httpResp.mimeType, textEncoding: httpResp.textEncodingName, httpHeaders: httpResp.allHeaderFields as! [String: String])
                        respMeta = meta

                        tracer?.didReceive(response: httpResp, to: req, for: self, meta: meta, data: data, id: txnID)

                        try self.validateResponse(self, httpResp, meta, data)

                        tracer?.didValidate(response: httpResp, to: req, for: self, meta: meta, data: data, id: txnID)

                        let payload = try self.processPayload(self, data, meta)

                        tracer?.didExtract(payload: payload, for: self, meta: meta, id: txnID)

                        try self.validatePayload(self, payload, data, meta)

                        tracer?.didValidate(payload: payload, for: self, meta: meta, id: txnID)

                        let result = TransactionResult.succeeded(payload, meta)
                        self.transactionCompleted(result, meta: meta, id: txnID, tracer: tracer)

                        self.call(completion, with: result)
                    }
                    catch {
                        let wrappedError = DataTransactionError.wrap(error)
                        let result = TransactionResult<HTTPResponseDataType, HTTPResponseMetadata>.failed(wrappedError)
                        self?.transactionCompleted(result, meta: respMeta, id: txnID, tracer: tracer)
                        self?.call(completion, with: result)
                    }
                }
            }

            req.httpBody = uploadData
            if let uploadData = uploadData {
                task = session.uploadTask(with: req, from: uploadData, completionHandler: handler)
            } else {
                task = session.dataTask(with: req, completionHandler: handler)
            }
            
            guard let task = task else {
                throw DataTransactionError.sessionTaskNotCreated
            }

            task.resume()   // this kicks off the HTTP request

            tracer?.didIssue(request: req, for: self, id: txnID)
        }
        catch {
            let result: Result = .failed(.wrap(error))
            transactionCompleted(result, meta: nil, id: txnID, tracer: tracer)
            call(completion, with: result)
        }
    }

    private func transactionCompleted(_ result: Result, meta: HTTPResponseMetadata?, id: UUID, tracer: HTTPTransactionTracer?)
    {
        tracer?.didComplete(transaction: self, result: result, meta: meta, id: id)

        transactionCompleted(result)
    }

    open func transactionCompleted(_ result: Result)
    {
        if case .succeeded(let data, let meta) = result {
            storeInCache?(self, data, meta)
        }
    }
}
