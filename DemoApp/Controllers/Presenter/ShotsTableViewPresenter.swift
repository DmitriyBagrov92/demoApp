//
//  ShotsTableViewPresenter.swift
//  DemoApp
//
//  Created by Багров Дмитрий on 27/08/16.
//  Copyright © 2016 jetBrains. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

let kShotsPageSize = 10

class ShotsTableViewPresenter: UITableViewObjectsDataSource {
    
    // MARK: - Public Properties
    
    var paginator: Paginator!
    
    // MARK: - Lifecycle
    
    override init() {
        super.init()
        self.paginator = Paginator(delegate: self)
    }
    
    // MARK: - Public Methods
    
    func presentShots() {
        configurePaginator()
        configureRefreshControl()
        
        performFirstShotsFetch()
    }
    
    func configurePaginator() {
        tableView?.delegate = paginator
    }
    
    func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(performFirstShotsFetch(_:)), forControlEvents: .ValueChanged)
        tableView?.addSubview(refreshControl)
    }
    
    func performFirstShotsFetch(sender: UIRefreshControl? = nil) {
        Shot.shots(0, limit: kShotsPageSize) { [weak self] (error, shots) in
            sender?.endRefreshing()
            if let _ = error {
                self?.objects = [Array(try! Realm().objects(Shot.self).sorted("createdAt"))]
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

extension ShotsTableViewPresenter: PaginatorDelegate {
    
    func paginator(paginator: Paginator, isNeedPerformFetchAtIndexPath indexPath: NSIndexPath) -> Bool {
        return objects[0].count - 1 == indexPath.row
    }
    
    func paginator(paginator: Paginator, needFetchNextPageWithCompletion completion: (reachEnd: Bool) -> Void) {
        Shot.shots(objects[0].count, limit: kShotsPageSize) { [weak self] (error, shots) in
            if let _ = error {
                // TODO: Insert cached shots
            } else if let shots = shots {
                self?.objects[0].appendContentsOf(shots.map({$0}))
                completion(reachEnd: shots.count < kShotsPageSize)
            }
        }
    }
    
}

