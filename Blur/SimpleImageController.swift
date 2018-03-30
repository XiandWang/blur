//
//  SimpleImageController.swift
//  Blur
//
//  Created by xiandong wang on 2/22/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import UIKit
import Hero

class SimpleImageController: UIViewController {
    
    let imageView : UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .black
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        self.hero.isEnabled = true
        imageView.hero.id = IMAGE_VIEW_HERO_ID
        
        view.addSubview(imageView)
        imageView.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: bottomLayoutGuide.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))
        view.addGestureRecognizer(tap)
    }
    
    @objc func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}
