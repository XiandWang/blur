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

    
     let faveButton = FaveButton(
        frame: CGRect(x:200, y:200, width: 50, height: 50),
        faveIconNormal: UIImage.fontAwesomeIcon(name: .heart, textColor: UIColor.red, size: CGSize(width: 44, height: 44))
    )
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        let alert = KOAlertController("How do you like it?", nil, UIImage.fontAwesomeIcon(name: .heart, textColor: PINK_COLOR, size: CGSize(width: 60, height: 60)))
        let style                       = KOAlertStyle()
        style.position = .center
        style.backgroundColor           = PURPLE_COLOR_LIGHT
        style.cornerRadius              = 15
        style.titleColor                = UIColor.white
        style.titleFont                 = UIFont.systemFont(ofSize: 24)

        let niceButton                   = KOAlertButton(.default, title:"😍Nice")
        niceButton.backgroundColor       = UIColor.white
        niceButton.titleColor            = .black
        niceButton.cornerRadius = 27.5
        niceButton.font = UIFont.boldSystemFont(ofSize: 17)
        niceButton.title = "😍Nice"

        let creativeButton                   = KOAlertButton(.default, title:"😂Creative")
        creativeButton.backgroundColor       = UIColor.white
        creativeButton.titleColor            = .black
        creativeButton.cornerRadius = 27.5
        creativeButton.font = UIFont.boldSystemFont(ofSize: 17)
        creativeButton.title = "😂Creative"

        let underwhelmButton                   = KOAlertButton(.default, title:"😐Underwhelmed")
        underwhelmButton.backgroundColor       = UIColor.white
        underwhelmButton.titleColor            = .black
        underwhelmButton.cornerRadius = 27.5
        underwhelmButton.font = UIFont.boldSystemFont(ofSize: 17)
        underwhelmButton.title = "😐Underwhelmed"


        alert.style = style
        alert.addAction(niceButton) {
            print("Action:nice")
        }
        alert.addAction(creativeButton) {
            print("Action:creative")
        }
        alert.addAction(underwhelmButton) {
            print("Action:underwhelm")
        }
        self.present(alert, animated: true) {}
        
        let imageView = UIImageView(image: #imageLiteral(resourceName: "speech_buble"))
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        
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

