//
//  Shot.swift
//  DemoApp
//
//  Created by Багров Дмитрий on 27/08/16.
//  Copyright © 2016 jetBrains. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

class Shot: BaseModel {
    
    dynamic var title: String?
    
    dynamic var image: Image?
    
    dynamic var shotDescription: String?
    
    dynamic var animated = false
    
    override func mapping(map: Map) {
        super.mapping(map)
        title <- map["title"]
        image <- map["images"]
        shotDescription <- map["description"]
        animated <- map["animated"]
        
        try! Realm().write({ 
            try! Realm().add(self, update: true)
        })
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // MARK: - Network
    
    class func shots(offset: NSNumber, limit: NSNumber, completion: (Error?, [Shot]?) -> Void) {
        GET(kShotsUrl, offset: offset, limit: limit, completion: completion)
    }
    
}