//
//  Image.swift
//  DemoApp
//
//  Created by Багров Дмитрий on 27/08/16.
//  Copyright © 2016 jetBrains. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

class Image: BaseModel {
    
    dynamic var hidpi: String?
    
    dynamic var normal: String?
    
    dynamic var teaser: String?
    
    override func mapping(map: Map) {
        hidpi <- map["hidpi"]
        normal <- map["normal"]
        teaser <- map["teaser"]
        
        try! Realm().write({
            try! Realm().add(self)
        })
    }
    
}