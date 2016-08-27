//
//  ViewController.swift
//  DemoApp
//
//  Created by Багров Дмитрий on 26/08/16.
//  Copyright © 2016 jetBrains. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - IBOutlets: Objects
    
    @IBOutlet var shotsPresenter: ShotsTableViewPresenter!
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        shotsPresenter.presentShots()
    }


}

