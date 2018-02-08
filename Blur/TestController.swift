//
//  TestController.swift
//  Blur
//
//  Created by xiandong wang on 9/21/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import FontAwesome_swift
import Firebase
import FaveButton
import KOAlertController

class TestController: UIViewController {

    
    let tf: AppTextField = {
        let tf = AppTextField()

        return tf
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(tf)
        tf.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
        tf.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        tf.layoutIfNeeded()
        tf.setupView()
        //tf.layoutIfNeeded()
    }

}

struct KOAlertButtonUtil {
    static func getAppButton(title: String)  -> KOAlertButton {
        let bt = KOAlertButton(.default, title: title)
        bt.backgroundColor = UIColor.white
        bt.titleColor = .black
        bt.cornerRadius = 27.5
        bt.font = UIFont.boldSystemFont(ofSize: 17)
        
        return bt
    }
}

