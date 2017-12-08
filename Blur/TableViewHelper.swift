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
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewController.view.bounds.size.width, height: viewController.view.bounds.size.height))
        
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.sizeToFit()
        
        viewController.tableView.backgroundView = messageLabel;
        viewController.tableView.separatorStyle = .none;
    }
    
    class func loadingView(viewController:UITableViewController) {
        let loader = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        loader.startAnimating()
        viewController.tableView.backgroundView = loader;
        viewController.tableView.separatorStyle = .none;
    }
}
