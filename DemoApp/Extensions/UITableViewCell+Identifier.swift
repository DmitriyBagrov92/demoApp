//
//  UITableViewCell+Identifier.swift
//  DemoApp
//
//  Created by Багров Дмитрий on 27/08/16.
//  Copyright © 2016 jetBrains. All rights reserved.
//

import UIKit

protocol Identifierable: class {
    var identifier: String { get }
}

extension Identifierable where Self: UITableViewCell {
    
    var identifier: String {
        return String(Self)
    }
    
}
