//
//  NetworkService.swift
//

import UIKit
import Alamofire

enum NetworkManagerTokenPolicy {
    case Unspecified
    case Master
    case User
}

internal class NetworkService {
    
    // MARK: - Constants
    
    let kNetworkServiceTimeoutInterval = 20.0
    
    let logRequest = true
    
    static let sharedInstance: NetworkService = {
        return NetworkService()
    }()
    
    class func GET(url: String, URLParameters: [String: String]? = nil, parameters: [String: AnyObject]? = nil, HTTPHeaderFields: [String: String]? = nil, HTTPBody: NSData? = nil, tokenPolicy: NetworkManagerTokenPolicy = .Unspecified, progress: ((Float) -> Void)? = nil, complete: ((NSURLRequest?, NSHTTPURLResponse?, AnyObject?, Error?) -> Void)? = nil) {
        return sharedInstance.request(.GET, url: url, URLParameters: URLParameters, parameters: parameters, HTTPHeaderFields: HTTPHeaderFields, HTTPBody: HTTPBody, tokenPolicy: tokenPolicy, progress: progress, complete: complete)
    }
    
    class func POST(url: String, URLParameters: [String: String]? = nil, parameters: [String: AnyObject]? = nil, HTTPHeaderFields: [String: String]? = nil, HTTPBody: NSData? = nil, tokenPolicy: NetworkManagerTokenPolicy = .Unspecified, progress: ((Float) -> Void)? = nil, complete: ((NSURLRequest?, NSHTTPURLResponse?, AnyObject?, Error?) -> Void)? = nil) {
        return sharedInstance.request(.POST, url: url, URLParameters: URLParameters, parameters: parameters, HTTPHeaderFields: HTTPHeaderFields, HTTPBody: HTTPBody, tokenPolicy: tokenPolicy, progress: progress, complete: complete)
    }
    
    class func PUT(url: String, URLParameters: [String: String]? = nil, parameters: [String: AnyObject]? = nil, HTTPHeaderFields: [String: String]? = nil, HTTPBody: NSData? = nil, tokenPolicy: NetworkManagerTokenPolicy = .Unspecified, progress: ((Float) -> Void)? = nil, complete: ((NSURLRequest?, NSHTTPURLResponse?, AnyObject?, Error?) -> Void)? = nil) {
        return sharedInstance.request(.PUT, url: url, URLParameters: URLParameters, parameters: parameters, HTTPHeaderFields: HTTPHeaderFields, HTTPBody: HTTPBody, tokenPolicy: tokenPolicy, progress: progress, complete: complete)
    }
    
    class func DELETE(url: String, URLParameters: [String: String]? = nil, parameters: [String: AnyObject]? = nil, HTTPHeaderFields: [String: String]? = nil, HTTPBody: NSData? = nil, tokenPolicy: NetworkManagerTokenPolicy = .Unspecified, progress: ((Float) -> Void)? = nil, complete: ((NSURLRequest?, NSHTTPURLResponse?, AnyObject?, Error?) -> Void)? = nil) {
        return sharedInstance.request(.DELETE, url: url, URLParameters: URLParameters, parameters: parameters, HTTPHeaderFields: HTTPHeaderFields, HTTPBody: HTTPBody, tokenPolicy: tokenPolicy, progress: progress, complete: complete)
    }
    
    class func UPLOAD(url: String, URLParameters: [String: String]? = nil, parameters: [String: AnyObject]? = nil, HTTPHeaderFields: [String: String]? = nil, HTTPBody: NSData? = nil, tokenPolicy: NetworkManagerTokenPolicy = .Unspecified, progress: ((Float) -> Void)? = nil, complete: ((NSURLRequest?, NSHTTPURLResponse?, AnyObject?, Error?) -> Void)? = nil) {
        return sharedInstance.upload(.POST, url: url, URLParameters: URLParameters, parameters: parameters, HTTPHeaderFields: HTTPHeaderFields, HTTPBody: HTTPBody, tokenPolicy: tokenPolicy, progress: progress, complete: complete)
    }
    
    class func REPLACE(url: String, URLParameters: [String: String]? = nil, parameters: [String: AnyObject]? = nil, HTTPHeaderFields: [String: String]? = nil, HTTPBody: NSData? = nil, tokenPolicy: NetworkManagerTokenPolicy = .Unspecified, progress: ((Float) -> Void)? = nil, complete: ((NSURLRequest?, NSHTTPURLResponse?, AnyObject?, Error?) -> Void)? = nil) {
        return sharedInstance.upload(.PUT, url: url, URLParameters: URLParameters, parameters: parameters, HTTPHeaderFields: HTTPHeaderFields, HTTPBody: HTTPBody, tokenPolicy: tokenPolicy, progress: progress, complete: complete)
    }
    
    /**
     Perform request with error detection
     
     - parameter method:     HTTP Method
     - parameter url:        Request URL
     - parameter parameters: Request Body parameters
     - parameter complete:   completion closure
     */
    func request(method: Alamofire.Method, url: String, URLParameters: [String: String]? = nil, parameters: [String: AnyObject]? = nil, HTTPHeaderFields: [String: String]? = nil, HTTPBody: NSData? = nil, tokenPolicy: NetworkManagerTokenPolicy = .Unspecified, progress: ((Float) -> Void)? = nil, complete: ((NSURLRequest?, NSHTTPURLResponse?, AnyObject?, Error?) -> Void)? = nil) {
        let request = constructRequestForMethod(
            method,
            url: url,
            URLParameters: URLParameters,
            parameters: parameters,
            HTTPHeaderFields: HTTPHeaderFields,
            HTTPBody: HTTPBody,
            tokenPolicy: tokenPolicy
        )
        
        Alamofire.request(request).responseJSON { response -> Void in
            self.logRequestAndResponse(request, response: response)
            self.saveTokenInResponseIfExist(response)
            self.complete(request, response: response.response, JSON: response.result.value, error: response.result.error, complete: complete)
            }.progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
                if let progress = progress {
                    let per = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                    dispatch_async(dispatch_get_main_queue()) {
                        progress(per)
                    }
                }
            }
    }
    
    /**
     Perform Multipart Uploading Request
     
     - parameter method:           HTTP Method
     - parameter url:              Request suburl. Will be contatinated with baseUrl in URLConstants
     - parameter URLParameters:    Dictionary of url parametrs
     - parameter parameters:       Request Body Parametrs
     - parameter HTTPHeaderFields: HTTP Headers
     - parameter HTTPBody:         HTTP body. Submit custom value in request Body
     - parameter tokenPolicy:      Token Policy
     - parameter progress:         progress closure
     - parameter complete:         completion closure
     */
    func upload(method: Alamofire.Method, url: String, URLParameters: [String: String]? = nil, parameters: [String: AnyObject]? = nil, HTTPHeaderFields: [String: String]? = nil, HTTPBody: NSData? = nil, tokenPolicy: NetworkManagerTokenPolicy = .Unspecified, progress: ((Float) -> Void)? = nil, complete: ((NSURLRequest?, NSHTTPURLResponse?, AnyObject?, Error?) -> Void)? = nil) {
        let request = constructRequestForMethod(
            method,
            url: url,
            URLParameters: URLParameters,
            parameters: parameters,
            HTTPHeaderFields: HTTPHeaderFields,
            HTTPBody: HTTPBody,
            tokenPolicy: tokenPolicy
        )
        
        Alamofire.upload(request, data: HTTPBody!).progress {
            (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
            if let progress = progress {
                let per = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                dispatch_async(dispatch_get_main_queue()) {
                    progress(per)
                }
            }
            }
            .responseJSON { response in
                self.complete(request, response: response.response, JSON: response.result.value, error: response.result.error, complete: complete)
        }
    }
    
    /**
     Request complete processor
     
     - parameter request:  NSURLRequest
     - parameter response: NSHTTPURLResponse
     - parameter JSON:     Response object
     - parameter error:    NSError
     - parameter complete: closure
     */
    private func complete(request: NSURLRequest?, response: NSHTTPURLResponse?, JSON: AnyObject?, error: ErrorType?, complete: ((NSURLRequest?, NSHTTPURLResponse?, AnyObject?, Error?) -> Void)? = nil) {
        var nsError: Error?
        
        if let status = response?.statusCode {
            switch status {
            case 200, 201, 204:
                complete?(request, response, JSON, nil)
                return
            case 400, 401, 404, 500, 403:
                complete?(request, response, nil, self.getErrorFromJSON(JSON))
                return
            case 415:
                nsError = Error(errorType: .UnsupportedContentType)
                break
            default:
                break
            }
        }
        
        if let _nsError = error as? NSError {
            nsError = Error(error: _nsError)
        } else if nsError == nil {
            nsError = Error(errorType: .Unknow)
        }
        
        complete?(request, response, nil, nsError)
    }
    
    /**
     Construct NSURLRequest for perform request
     
     - parameter method:     HTTP Method
     - parameter url:        Request URL
     - parameter parameters: Request Body parameters
     
     - returns: NSURLRequest object
     */
    private func constructRequestForMethod(method: Alamofire.Method, url: String, URLParameters: [String: String]? = nil, parameters: [String: AnyObject]? = nil, HTTPHeaderFields: [String: String]? = nil, HTTPBody: NSData? = nil, tokenPolicy: NetworkManagerTokenPolicy = .Unspecified) -> NSURLRequest {
        var completeURL = url
        
        if let URLParameters = URLParameters {
            
            completeURL = url + "?"
            
            for URLParameter in URLParameters {
                completeURL += String(format: "%@=%@&", URLParameter.0, URLParameter.1.URLEncode)
            }
            
            completeURL = completeURL.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "&"))
        }
        
        let url = NSURL(string: completeURL)!
        let mutableURLRequest = NSMutableURLRequest(URL: url)
        mutableURLRequest.HTTPMethod = method.rawValue
        
        //var JSONSerializationError: NSError? = nil
        if let safeParameters = parameters {
            do {
                mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(
                    safeParameters,
                    options: []
                )
            } catch _ {
                //JSONSerializationError = error
                mutableURLRequest.HTTPBody = nil
            }
        }
        
        if let HTTPBody = HTTPBody {
            mutableURLRequest.HTTPBody = HTTPBody
        }
        
        buildHTTPHeaderFieldsForRequest(
            mutableURLRequest,
            HTTPHeaderFields: HTTPHeaderFields,
            tokenPolicy: tokenPolicy,
            HTTPBody: HTTPBody
        )
        
        return mutableURLRequest
    }
    
    private func saveTokenInResponseIfExist(response: (Response<AnyObject, NSError>)?) {
        if let JSON = response?.result.value as? NSDictionary, _ = JSON.valueForKeyPath("data.token") as? String {
            // TODO: Save token
        }
    }
    
    private func logRequest(request: NSURLRequest) {
        print("")
        print("--- NEW REQUEST ---")
        print(" \(request.HTTPMethod!) \(request.URL!) ")
        if let body = request.HTTPBody {
            print("--- BODY ---")
            if let jsonDict = (try? NSJSONSerialization.JSONObjectWithData(body, options: [])) as? NSDictionary {
                print(jsonDict)
            } else {
                print("binary")
            }
        }
    }
    
    private func logRequestAndResponse(request: NSURLRequest, response: (Response<AnyObject, NSError>)?) {
        logRequest(request)
        print("--- RESPONSE ---")
        if let JSON = response?.result.value as? NSDictionary {
            print(JSON)
        }
    }
    
    /**
     Build HTTP header fields for mutable url request
     
     - parameter mutableURLRequest: NSMutableURLRequest
     - parameter HTTPHeaderFields:  HTTP Header Fields
     - parameter tokenPolicy:       case of NetworkManagerTokenPolicy enum
     */
    private func buildHTTPHeaderFieldsForRequest(mutableURLRequest: NSMutableURLRequest, HTTPHeaderFields: [String: String]?, tokenPolicy: NetworkManagerTokenPolicy = .Unspecified, HTTPBody: NSData? = nil) -> NSMutableURLRequest {
        if let data = HTTPBody {
            mutableURLRequest.setValue("image/png", forHTTPHeaderField: "Content-Type")
            mutableURLRequest.setValue("\(data.length)", forHTTPHeaderField: "Content-Length")
        } else {
            mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        
        if let HTTPHeaderFields = HTTPHeaderFields {
            for item in HTTPHeaderFields {
                mutableURLRequest.setValue(item.1, forHTTPHeaderField: item.0)
            }
        }
    
        // TODO: Attach token
        mutableURLRequest.setValue(kDribbleAuthorisationToken, forHTTPHeaderField: "Authorization")
        
        mutableURLRequest.timeoutInterval = kNetworkServiceTimeoutInterval
        return mutableURLRequest
    }
    
    /**
     Get Error object from server response object
     
     - parameter JSON: server response object
     
     - returns: Error object with NetworkManagerError and localized description
     */
    private func getErrorFromJSON(JSON: AnyObject?) -> Error? {
        if let errors = JSON?["errors"] as? [String : AnyObject], errorDescription = errors["error"] as? String {
            return Error(description: errorDescription)
        } else if let errorDescription = JSON?["errors"] as? String {
            return Error(description: errorDescription)
        } else {
            return Error(errorType: .Unknow)
        }
    }
    
}
