//
//  TypeInviterController.swift
//  Blur
//
//  Created by xiandong wang on 4/29/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

//
//  EditFullNameController.swift
//  Blur
//
//  Created by xiandong wang on 2/21/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import UIKit
import Firebase

class TypeInviterController: UIViewController, UITextFieldDelegate {
    
    var delegate: InviteDelegate?
    
    let usernameTextField: AppTextField = {
        let tf = AppTextField()
        tf.borderStyle = .none
        tf.placeholder = "Type your friend's username"
        tf.clearButtonMode = .whileEditing
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.returnKeyType = .done
        tf.backgroundColor = .white
        tf.font = TEXT_FONT
        tf.addTarget(self, action: #selector(handleInputChange), for: .editingChanged)
        return tf
    }()
    
    let submitButton : UIButton = {
        let bt = UIButton(type: .system)
        bt.setTitle("Submit", for: .normal)
        bt.setTitleColor(.black, for: .normal)
        bt.titleLabel?.font = BOLD_FONT
        bt.backgroundColor = YELLOW_COLOR
        bt.layer.cornerRadius = 22
        bt.isEnabled = false
        bt.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return bt
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Who invites you?"
        
        view.addSubview(usernameTextField)
        
        usernameTextField.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 44)
        usernameTextField.layoutIfNeeded()
        usernameTextField.setupView()
        usernameTextField.becomeFirstResponder()
        usernameTextField.delegate = self
        
        view.addSubview(submitButton)
        submitButton.anchor(top: usernameTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 44)
        UIView.addShadow(for: submitButton)
        
    }
    
    @objc func handleInputChange() {
        if let fullName = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), fullName.count < 32 && fullName.count > 0 {
            self.submitButton.isEnabled = true
        } else {
            self.submitButton.isEnabled = false
        }
    }
    
    @objc func handleSubmit() {
        usernameTextField.resignFirstResponder()
        guard let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }
        AppHUD.progress(nil, isDarkTheme: true)
        
        
        
        Database.database().reference().child("usernames").child(username).observeSingleEvent(of: .value, with: { (snap) in
            if snap.exists() {
                AppHUD.progressHidden()
                self.navigationController?.popViewController(animated: true)
                self.delegate?.invitesDidSend(self)
            } else {
                AppHUD.progressHidden()
                AppHUD.error("The username does not exist. Please try again.", isDarkTheme: true)
            }
        }) { (error) in
            AppHUD.progressHidden()
            AppHUD.error(error.localizedDescription, isDarkTheme: true)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.handleSubmit()
        return true
    }
}

