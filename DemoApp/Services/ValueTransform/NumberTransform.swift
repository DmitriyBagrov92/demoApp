//
//  NumberTransform.swift
//

import Foundation
import ObjectMapper

public class NumberTransform: TransformType {
    public typealias Object = NSNumber
    public typealias JSON = NSNumber
    
    public init() {}
    
    public func transformFromJSON(value: AnyObject?) -> NSNumber? {
        if let stringValue = value as? String {
            return NSNumber(string: stringValue)
        } else if let numberValue = value as? NSNumber {
            return numberValue
        }
        return nil
    }
    
    public func transformToJSON(value: NSNumber?) -> NSNumber? {
        return value
    }
}
