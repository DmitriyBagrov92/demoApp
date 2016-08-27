//
//  ViewController.swift
//  DemoApp
//
//  Created by Багров Дмитрий on 26/08/16.
//  Copyright © 2016 jetBrains. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Shot.shots(0, limit: 10) { (error, shots) in
            print(error)
        }
    }


}

