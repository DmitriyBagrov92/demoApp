//
//  ShotsTableViewPresenter.swift
//  DemoApp
//
//  Created by Багров Дмитрий on 27/08/16.
//  Copyright © 2016 jetBrains. All rights reserved.
//

import UIKit

class ShotsTableViewPresenter: UITableViewObjectsDataSource {
    
    // MARK: - Private Proprties

    private var shots: [Shot] = []
    
    // MARK: - Public Methods
    
    func presentShots() {
        Shot.shots(0, limit: 10) { [weak self] (error, shots) in
            if let _ = error {
                // TODO: Present Cached shots
            } else if let shots = shots {
                self?.objects = [shots]
            }
        }
    }
    
    // MARK: - ShotsTableViewPresenter
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, withObject object: AnyObject) -> UITableViewCell {
        return cellForShotRowAtIndexPath(indexPath, withShot: object as? Shot) ?? UITableViewCell()
    }
    
    func cellForShotRowAtIndexPath(indexPath: NSIndexPath, withShot shot: Shot?) -> UITableViewCell? {
        let cell = tableView?.dequeueReusableCellWithIdentifier(ShotTableViewCell().identifier) as? ShotTableViewCell
        cell?.presentImage(shot?.image)
        cell?.presentTitle(shot?.title)
        cell?.presentDescription(shot?.shotDescription)
        return cell
    }
    
}