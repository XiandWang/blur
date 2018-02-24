//
//  EditFullNameController.swift
//  Blur
//
//  Created by xiandong wang on 2/21/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import UIKit
import Firebase

class EditFullNameController: UIViewController {
    var user: User?
    
    let editTextField: AppTextField = {
        let tf = AppTextField()
        tf.borderStyle = .none
        tf.placeholder = "Full Name"
        tf.clearButtonMode = .whileEditing
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.returnKeyType = .done
        tf.backgroundColor = .white
        tf.font = TEXT_FONT
        tf.addTarget(self, action: #selector(handleInputChange), for: .editingChanged)
        return tf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Edit"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(updateFullName))
        navigationItem.rightBarButtonItem?.isEnabled = false
        view.addSubview(editTextField)
    
        editTextField.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 48)
        editTextField.layoutIfNeeded()
        editTextField.setupView()
        editTextField.delegate = self
        editTextField.becomeFirstResponder()
    }
    
    @objc func handleInputChange() {
        if let fullName = editTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), fullName.count < 32 && fullName.count > 2 {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    @objc func updateFullName() {
        editTextField.resignFirstResponder()
        guard var user = user else { return }
        guard let fullName = editTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), fullName.count < 32 && fullName.count > 2 else {
            AppHUD.error("Full name should have more than 2 characters and less than 32 characters.", isDarkTheme: true)
            return
        }
        AppHUD.progress(nil, isDarkTheme: true)
        let update = ["/\(USERS_NODE)/\(user.uid)/fullName": fullName]
        Database.database().reference().updateChildValues(update) { (error, ref) in
            if let error = error {
                AppHUD.progressHidden()
                AppHUD.error(error.localizedDescription, isDarkTheme: true)
                return
            }
            AppHUD.progressHidden()
            user.fullName = fullName
            NotificationCenter.default.post(name: USER_CHANGED, object: nil, userInfo: ["user": user])
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension EditFullNameController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.updateFullName()
        return true
    }
}
