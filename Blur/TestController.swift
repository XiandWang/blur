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
import AZDialogView
import SCLAlertView
import JSSAlertView

class TestController: UIViewController {

    var picker: GSTimeIntervalPicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
         picker = GSTimeIntervalPicker()
        view.addSubview(picker)
        picker.maxTimeInterval = 3600
        picker.minuteInterval = 60
        picker.allowZeroTimeInterval = true
        picker.layer.addBorder(edge: .top, color: BACKGROUND_GRAY, thickness: 1.0)
        picker.layer.addBorder(edge: .bottom, color: BACKGROUND_GRAY, thickness: 1.0)
        picker.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 217)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
    
        let view = SCLAlertView(appearance: SCLAlertView.getAppearance())
        let textView = view.addTextView()
        view.addButton("Send", backgroundColor: PURPLE_COLOR_LIGHT, textColor: UIColor.white) {
            
            if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                AppHUD.error("empty...", isDarkTheme: true)
            } else {
                view.hideView()
            }
            
        }

        
       let image = UIImage.fontAwesomeIcon(name: .pencil, textColor: .white, size: CGSize(width: 40, height: 40))
       view.showCustom("Compliment", subTitle: "(please be direct and sincere)", color: PURPLE_COLOR_LIGHT, icon: image)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

}

extension SCLAlertView {
    static func getAppearance() -> SCLAppearance {
        let font = UIFont(name: APP_FONT_BOLD, size: 22) ?? UIFont.boldSystemFont(ofSize: 22)
        let windowWidth = UIScreen.main.bounds.width / 4.0 * 3
        return
            SCLAlertView.SCLAppearance(kCircleIconHeight: 40.0 , kWindowWidth: windowWidth, kButtonHeight: 50,                                   kTitleFont:font, kTextFont: TEXT_FONT, kButtonFont: BOLD_FONT, showCloseButton: false,
                showCircularIcon: true, shouldAutoDismiss: false, contentViewCornerRadius: 15, fieldCornerRadius: 3.0,
                buttonCornerRadius: 17.5, hideWhenBackgroundViewIsTapped: true, circleBackgroundColor: .white, titleColor: .black)
    }
    
    
}

