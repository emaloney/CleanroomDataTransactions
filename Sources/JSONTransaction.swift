//
//  JSONTransaction.swift
//  CleanroomDataTransactions
//
//  Created by Evan Maloney on 7/28/15.
//  Copyright © 2015 Gilt Groupe. All rights reserved.
//

import Foundation
import CleanroomConcurrency
import CleanroomLogger

//enum EnvelopeKey: String, JSONDataKey
//{
//    case Status = "status"
//    case Payload = "data"
//    case Message = "message"
//}

public func simplePayloadProcessor<T>(jsonObject: AnyObject?)
    throws
    -> T
{
    guard let typed = jsonObject as? T else {
        throw DataTransactionError.DataFormatError("Expecting JSON data to be a type of \(T.self); got \(jsonObject.dynamicType) instead")
    }
    return typed
}

public func optionalPayloadProcessor<T>(jsonObject: AnyObject?)
    throws
    -> T?
{
    guard let object = jsonObject else {
        return nil
    }

    guard let typed = object as? T else {
        throw DataTransactionError.DataFormatError("Expecting JSON data to be a type of \(T.self); got \(object.dynamicType) instead")
    }

    return typed
}

//public func processGiltMobileServicesEnvelope(jsonObject: AnyObject?)
//    throws
//    -> NSDictionary
//{
//    let data: NSDictionary = try simplePayloadProcessor(jsonObject)
//
//    let status = try data.requiredInt(EnvelopeKey.Status)
//
//    guard status == 0 else {
//        throw DataTransactionError.FormatError("Expected \"\(EnvelopeKey.Status.rawValue)\" key to be equal to zero")
//    }
//
//    let payload = try data.requiredDictionary(EnvelopeKey.Payload)
//
//    if let message = payload[EnvelopeKey.Message] as? String {
//        throw DataTransactionError.GenericError(message)
//    }
//
//    return payload
//}

public func httpStatusCodeHandler<MetadataType, DataType>(meta: MetadataType?, payload: DataType, httpRequired: Bool)
    throws
{
    guard let http = meta as? HTTPResponseMetadata else {
        if httpRequired {
            throw DataTransactionError.HTTPRequired
        } else {
            return  // assume success
        }
    }

    let status = http.responseStatus

    Log.debug?.message("HTTP \(status.statusCode): \(status)")

    if status.isErrorResponse {
        throw DataTransactionError.HTTPError(http, nil)
    }
}

public func httpOptionalStatusCodeHandler<MetadataType, DataType>(meta: MetadataType?, payload: DataType)
    throws
{
    try httpStatusCodeHandler(meta, payload: payload, httpRequired: false)
}

public func httpRequiredStatusCodeHandler<MetadataType, DataType>(meta: MetadataType?, payload: DataType)
    throws
{
    try httpStatusCodeHandler(meta, payload: payload, httpRequired: true)
}

public class JSONTransaction<JSONDataType>: DelegatingDataTransaction
{
    public typealias DataType = JSONDataType
    public typealias MetadataType = DelegateTransactionType.MetadataType
    public typealias Result = TransactionResult<DataType, MetadataType>
    public typealias Callback = (Result) -> Void
//#if OFFLINE_MODE
//    public typealias DelegateTransactionType = OfflineURLTransaction
//#else
    public typealias DelegateTransactionType = URLTransaction
//#endif
    public typealias JSONPayloadProcessor = (AnyObject?) throws -> DataType
    public typealias MetadataProcessor = (MetadataType?, payload: DataType) throws -> Void

    public var delegateTransaction: DelegateTransactionType? { return innerTransaction }
    private let innerTransaction: DelegateTransactionType

    public var url: NSURL { return innerTransaction.url }

    public var jsonReadingOptions = NSJSONReadingOptions(rawValue: 0)
    public var payloadProcessingFunction: JSONPayloadProcessor = simplePayloadProcessor
    public var metadataProcessingFunction: MetadataProcessor?

    public init(request: NSURLRequest, uploadData: NSData? = nil)
    {
        innerTransaction = DelegateTransactionType(request: request, uploadData: uploadData)
    }

    public init(url: NSURL, uploadData: NSData? = nil)
    {
        innerTransaction = DelegateTransactionType(url: url, uploadData: uploadData)
    }

    public func executeTransaction(completion: Callback)
    {
        Log.verbose?.trace()

        innerTransaction.executeTransaction() { result in
            Log.verbose?.trace()

            switch result {
            case .Failed(let error):
                completion(.Failed(error))

            case .Succeeded(let data, let meta):
                async {
                    do {
                        let json: AnyObject?
                        if data.length > 0 {
                            json = try NSJSONSerialization.JSONObjectWithData(data, options: self.jsonReadingOptions)
                        } else {
                            json = nil
                        }

                        let payload = try self.payloadProcessingFunction(json)

                        if let metadataProcessor = self.metadataProcessingFunction {
                            try metadataProcessor(meta, payload: payload)
                        }

                        completion(.Succeeded(payload, meta))

                        Log.debug?.message("Successful transaction with \(self.url)")
                    }
                    catch {
                        completion(.Failed(.wrap(error)))

                        let orig = NSString(data: data, encoding: NSUTF8StringEncoding)!

                        Log.error?.message("\(self.url): \(orig)")
                    }
                }
            }
        }
    }
}

public typealias JSONDictionaryTransaction = JSONTransaction<NSDictionary>

//public class GiltMobileServicesTransaction: JSONDictionaryTransaction
//{
//    public override init(request: NSURLRequest, uploadData: NSData? = nil)
//    {
//        super.init(request: request, uploadData: uploadData)
//
//        payloadProcessingFunction = processGiltMobileServicesEnvelope
//    }
//
//    public override init(url: NSURL, uploadData: NSData? = nil)
//    {
//        super.init(url: url, uploadData: uploadData)
//
//        payloadProcessingFunction = processGiltMobileServicesEnvelope
//    }
//}

public typealias JSONArrayTransaction = JSONTransaction<NSArray>

public class ApiDocTransaction<T>: JSONTransaction<T>
{
    public override init(request: NSURLRequest, uploadData: NSData? = nil)
    {
        super.init(request: request, uploadData: uploadData)

        metadataProcessingFunction = httpRequiredStatusCodeHandler
    }

    public override init(url: NSURL, uploadData: NSData? = nil)
    {
        super.init(url: url, uploadData: uploadData)

        metadataProcessingFunction = httpRequiredStatusCodeHandler
    }
}

public typealias ApiDocDictionaryTransaction = ApiDocTransaction<NSDictionary>

public typealias ApiDocArrayTransaction = ApiDocTransaction<NSArray>

public class JSONOptionalTransaction<T>: JSONTransaction<T?>
{
    public override init(request: NSURLRequest, uploadData: NSData? = nil)
    {
        super.init(request: request, uploadData: uploadData)

        payloadProcessingFunction = optionalPayloadProcessor
    }

    public override init(url: NSURL, uploadData: NSData? = nil)
    {
        super.init(url: url, uploadData: uploadData)

        payloadProcessingFunction = optionalPayloadProcessor
    }
}

public typealias JSONOptionalDictionaryTransaction = JSONOptionalTransaction<NSDictionary>

public typealias JSONOptionalArrayTransaction = JSONOptionalTransaction<NSArray>

public class ApiDocOptionalTransaction<T>: JSONOptionalTransaction<T>
{
    public override init(request: NSURLRequest, uploadData: NSData? = nil)
    {
        super.init(request: request, uploadData: uploadData)

        payloadProcessingFunction = optionalPayloadProcessor
        metadataProcessingFunction = httpRequiredStatusCodeHandler
    }

    public override init(url: NSURL, uploadData: NSData? = nil)
    {
        super.init(url: url, uploadData: uploadData)

        payloadProcessingFunction = optionalPayloadProcessor
        metadataProcessingFunction = httpRequiredStatusCodeHandler
    }
}

public typealias ApiDocOptionalDictionaryTransaction = ApiDocOptionalTransaction<NSDictionary>

public typealias ApiDocOptionalArrayTransaction = ApiDocOptionalTransaction<NSArray>
