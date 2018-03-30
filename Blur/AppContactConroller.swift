//
//  AppContactConroller.swift
//  Blur
//
//  Created by xiandong wang on 3/28/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import UIKit

class AppContactController: UIViewController {
    
    let contactLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "HidingChat is created with ♥️ by Xiandong Wang. For contact or feedback, please send a email to hidingchat.contact@gmail.com. Thank you! "
        
        label.font = UIFont(name: APP_FONT, size: 17)
        label.textColor = TEXT_GRAY
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = BACKGROUND_GRAY
        navigationItem.title = "Contact"
        view.addSubview(contactLabel)
        contactLabel.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        contactLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
