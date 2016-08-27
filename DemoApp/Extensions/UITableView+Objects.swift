//
//  UITableView+Objects.swift
//  DemoApp
//
//  Created by Багров Дмитрий on 27/08/16.
//  Copyright © 2016 jetBrains. All rights reserved.
//

import UIKit

class UITableViewObjectsDataSource: NSObject {
    
    @IBOutlet weak var tableView: UITableView?
    
    var objects: [[AnyObject]] = [[]] {
        didSet {
            tableView?.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, withObject object: AnyObject) -> UITableViewCell {
        return UITableViewCell()
    }

}

extension UITableViewObjectsDataSource: UITableViewDataSource {
    
    @objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return objects.count
    }
    
    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects[section].count
    }
    
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.tableView(tableView, cellForRowAtIndexPath: indexPath, withObject: objects[indexPath.section][indexPath.row])
    }
    
}
