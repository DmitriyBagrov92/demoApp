//
//  BaseModel.swift
//

import Foundation
import ObjectMapper
import Realm
import RealmSwift

public class BaseModel: Object, Mappable {
    
    // MARK: - Properties
    
    dynamic var id: String?
    
    // MARK: - Lifecycle
    
    public required init() {
        super.init()
    }
    
    required public init?(_ map: Map){
        super.init()
    }
    
    required public init(realm: RLMRealm, schema: RLMObjectSchema) {
        fatalError("init(realm:schema:) has not been implemented")
    }
    
    required public init(value: AnyObject, schema: RLMSchema) {
        fatalError("init(value:schema:) has not been implemented")
    }
    
    public class func newInstance(map: Map) -> Mappable? {
        return BaseModel()
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
    }
    
    // MARK: - Network
    
    class func GET<T: Mappable>(url: String, urlParams: [String : String] = [:], jsonArrayPath: String? = nil, offset: NSNumber? = nil, limit: NSNumber? = nil, completion: (Error?, [T]?) -> Void) {
        var urlParams_ = urlParams
        //Pagination example
        if let limit = limit, offset = offset {
            urlParams_["per_page"] = limit.stringValue
            urlParams_["page"]   = offset.stringValue
        }
        NetworkService.GET(url, URLParameters: urlParams_) { (request, response, JSON, error) in
            if let error = error {
                completion(error, nil)
            } else if let jsonArrayPath = jsonArrayPath, rawObjects = JSON?.valueForKeyPath(jsonArrayPath) as? [AnyObject] {
                completion(nil, Mapper<T>().mapArray(rawObjects))
            } else if let rawObjects = JSON as? [AnyObject] {
                completion(nil, Mapper<T>().mapArray(rawObjects))
            } else {
                completion(Error(errorType: .WrongEntityJSONFormat), nil)
            }
        }
    }
    
    class func GET<T: Mappable>(url: String, urlParams: [String : String]? = nil, jsonObjectPath: String? = nil, completion: (Error?, T?) -> Void) {
        NetworkService.GET(url, URLParameters: urlParams) { (request, response, JSON, error) in
            if let error = error {
                completion(error, nil)
            } else if let jsonObjectPath = jsonObjectPath, rawObject = JSON?.valueForKeyPath(jsonObjectPath) {
                completion(nil, Mapper<T>().map(rawObject))
            } else if let rawObject = JSON {
                completion(nil, Mapper<T>().map(rawObject))
            } else {
                completion(Error(errorType: .WrongEntityJSONFormat), nil)
            }
        }
    }
    
    class func POST(url: String, urlParams: [String : String] = [:], params: [String : AnyObject]? = nil, completion: (Error?) -> Void) {
        NetworkService.POST(url, URLParameters: urlParams, parameters: params) { (request, response, JSON, error) in
            completion(error)
        }
    }
    
    class func POST<T: Mappable>(url: String, urlParams: [String : String] = [:], params: [String : AnyObject]? = nil, completion: (Error?, T?) -> Void) {
        NetworkService.POST(url, URLParameters: urlParams, parameters: params) { (request, response, JSON, error) in
            if let error = error {
                completion(error, nil)
            } else if let rawJSON = JSON as? [String : AnyObject], object = Mapper<T>().map(rawJSON) {
                completion(nil, object)
            } else {
                completion(Error(errorType: .WrongEntityJSONFormat), nil)
            }
        }
    }
    
    class func PUT(url: String, urlParams: [String : String]? = nil, params: [String : AnyObject]? = nil, completion: (Error?) -> Void) {
        NetworkService.PUT(url, URLParameters: urlParams, parameters: params) { (request, response, JSON, error) in
            completion(error)
        }
    }
    
    class func DELETE(url: String, urlParams: [String : String]? = nil, completion: (Error?) -> Void) {
        NetworkService.DELETE(url, URLParameters: urlParams) { (request, response, JSON, error) in
            completion(error)
        }
    }

}
