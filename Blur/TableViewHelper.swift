//
//  TableViewHelper.swift
//  Blur
//
//  Created by xiandong wang on 10/20/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit

class TableViewHelper {
    class func emptyMessage(message:String, detail: String? = nil, viewController:UITableViewController) {
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = TEXT_GRAY
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: APP_FONT_BOLD, size: 24)
        messageLabel.sizeToFit()
 
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: viewController.view.width, height: viewController.view.height))
        containerView.addSubview(messageLabel)
        let offset = (detail == nil) ? 0 : -20
        messageLabel.anchor(top: nil, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        messageLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: CGFloat(offset)).isActive = true
        
        if let detail = detail {
            let detailLabel = UILabel()
            detailLabel.text = detail
            detailLabel.textColor = TEXT_GRAY
            detailLabel.numberOfLines = 0;
            detailLabel.textAlignment = .center;
            detailLabel.font = UIFont(name: APP_FONT, size: 20)
            detailLabel.sizeToFit()
            containerView.addSubview(detailLabel)
            detailLabel.anchor(top: messageLabel.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        }
        
        viewController.tableView.backgroundView = containerView;
        viewController.tableView.separatorStyle = .none;
    }
    
    class func loadingView(viewController:UITableViewController) {
        let loader = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        loader.startAnimating()
        viewController.tableView.backgroundView = loader;
        viewController.tableView.separatorStyle = .none;
    }
}
