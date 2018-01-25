//
//  TableViewHelper.swift
//  Blur
//
//  Created by xiandong wang on 10/20/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit

class TableViewHelper {
    class func emptyMessage(message:String, viewController:UITableViewController) {
        let image = UIImage.fontAwesomeIcon(name: .comments, textColor: TEXT_GRAY, size: CGSize(width: 80, height: 80))
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
    
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = TEXT_GRAY
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont.boldSystemFont(ofSize: 24)
        messageLabel.sizeToFit()
 
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: viewController.view.width, height: viewController.view.height))
        //containerView.addSubview(imageView)
        containerView.addSubview(messageLabel)
//        imageView.anchor(top: nil, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 80)
        messageLabel.anchor(top: nil, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        messageLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        viewController.tableView.backgroundView = containerView;
        
        viewController.view.backgroundColor = BACKGROUND_GRAY
        viewController.tableView.separatorStyle = .none;
    }
    
    class func loadingView(viewController:UITableViewController) {
        let loader = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        loader.startAnimating()
        viewController.tableView.backgroundView = loader;
        viewController.tableView.separatorStyle = .none;
    }
}
