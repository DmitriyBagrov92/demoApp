//
//  ShotTableViewCell.swift
//  DemoApp
//
//  Created by Багров Дмитрий on 27/08/16.
//  Copyright © 2016 jetBrains. All rights reserved.
//

import UIKit
import Haneke

class ShotTableViewCell: UITableViewCell, Identifierable {
    
    // MARK: - IBOutlets: Views
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    // MARK: - Presentation

    func presentImage(image: Image?) {
        backgroundImageView.image = nil
        if let hidpi = image?.hidpi, url = NSURL(string: hidpi) {
            backgroundImageView.hnk_setImageFromURL(url)
        } else if let normal = image?.normal, url = NSURL(string: normal) {
            backgroundImageView.hnk_setImageFromURL(url)
        }
    }
    
    func presentTitle(title: String?) {
        titleLabel.text = title
    }
    
    func presentDescription(description: String?) {
        descriptionLabel.text = description
    }
    
}
