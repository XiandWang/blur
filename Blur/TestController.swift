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
import AZDialogView

class TestController: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let dialog = AZDialogViewController(title: "Request mood?", message: nil)
        dialog.cancelEnabled = true
        dialog.cancelTitle = "cancel"
        
        dialog.dismissWithOutsideTouch = false

        dialog.imageHandler = { (imageView) in
            imageView.image = UIImage.fontAwesomeIcon(name: .heart, textColor: PINK_COLOR, size: CGSize(width: 50, height: 50))
            imageView.backgroundColor = PINK_COLOR_LIGHT
            imageView.contentMode = .center
            return true //must return true, otherwise image won't show.
        }
        
        dialog.addAction(AZDialogAction(title: "Edit Name") { (dialog) -> (Void) in
            
            dialog.dismiss()
        })
        
        dialog.addAction(AZDialogAction(title: "Remove Friend") { (dialog) -> (Void) in
            //add your actions here.
            dialog.dismiss()
        })
        
        dialog.addAction(AZDialogAction(title: "Block") { (dialog) -> (Void) in
            //add your actions here.
            dialog.dismiss()
        })
        dialog.show(in: self)
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

