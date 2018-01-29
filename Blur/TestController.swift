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

class TestController: UIViewController {
    
    var originalScrollView: UIScrollView = UIScrollView()
    let originalImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        let img = UIImage.fontAwesomeIcon(name: .exclamationCircle, textColor: YELLOW_COLOR, size: CGSize(width: 1000, height: 1000))
        iv.image = img
        return iv
    }()
    
     let faveButton = FaveButton(
        frame: CGRect(x:200, y:200, width: 50, height: 50),
        faveIconNormal: UIImage.fontAwesomeIcon(name: .heart, textColor: UIColor.red, size: CGSize(width: 44, height: 44))
    )
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        faveButton.layer.cornerRadius = 25
        faveButton.layer.masksToBounds = true
        faveButton.backgroundColor = .white
        faveButton.dotSecondColor = UIColor.rgb(red: 25, green: 118, blue: 210, alpha: 1)
        faveButton.dotFirstColor = UIColor.rgb(red: 244, green: 143, blue: 177, alpha: 1)
        faveButton.normalColor = TEXT_GRAY
        faveButton.selectedColor = .red
        faveButton.addTarget(self, action: #selector(p), for: .touchUpInside)
        faveButton.delegate = self
        view.addSubview(faveButton)
        
        faveButton.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 50, paddingLeft: 50, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
    }
    
    @objc func p() {
        print(self.faveButton.dotFirstColor)
        print(self.faveButton.dotSecondColor)
        print("fang pi")
        if self.faveButton.isSelected {
            //self.faveButton.isEnabled = false
        }
    }
    
    func faveButtonDotColors(_ faveButton: FaveButton) -> [DotColors]?{
        if faveButton == self.faveButton {
            let PINK = UIColor.rgb(red: 194, green: 24, blue: 91, alpha: 1)
            let LIGHT_PINK = UIColor.rgb(red: 244, green: 143, blue: 177, alpha: 1)
            let blue = UIColor.rgb(red: 25, green: 118, blue: 210, alpha: 1)
            let LIGHT_BLUE = UIColor.rgb(red: 144, green: 202, blue: 249, alpha: 1)
            return [DotColors(first: PINK, second: LIGHT_PINK), DotColors(first: blue, second: LIGHT_BLUE)]
        }
        return nil
    }
   
}

