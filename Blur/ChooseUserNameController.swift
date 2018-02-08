//
//  ChooseUserNameController.swift
//  Blur
//
//  Created by xiandong wang on 12/2/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit
import Firebase

class ChooseUserNameController: UIViewController, UITextFieldDelegate {
    var uid: String?
    private let legalCharSet = Set(Array("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-_"))
    
    let usernameTextField: AppTextField = {
        let tf = AppTextField()
        tf.borderStyle = .none
        tf.placeholder = "Username"
        tf.clearButtonMode = .whileEditing
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.keyboardType = .alphabet
        tf.returnKeyType = .done
        tf.backgroundColor = UIColor(white: 1, alpha:1)
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        
        
        return tf
    }()
    
    let chooseUserNameLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Choose Username"
        lb.font = UIFont.boldSystemFont(ofSize: 20)
        lb.textColor = .white
        lb.textAlignment = .center
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    let usernameDescriptionLabel: UILabel = {
        let lb = UILabel()
        lb.text = "（Username is your unique identifier in Hidingchat）"
        lb.font = UIFont.systemFont(ofSize: 14)
        lb.textAlignment = .center
        lb.textColor = TEXT_GRAY
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    let submitButton: UIButton = {
        let bt = UIButton(type: .system)
        bt.backgroundColor = .lightGray
        bt.isEnabled = false
        bt.setTitle("Submit", for: .normal)
        bt.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        bt.setTitleColor(.white, for: .normal)
        bt.layer.cornerRadius = 20
        bt.addTarget(self, action: #selector(handleUpdateUsername), for: .touchUpInside)
        return bt
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BACKGROUND_GRAY
        usernameTextField.delegate = self
        setupViews()
        usernameTextField.becomeFirstResponder()
        
    }
    
    @objc func handleUpdateUsername() {
        guard let name = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), name.count < 16 && name.count > 2 else {
            AppHUD.error("username should have more than 2 characters and less than 16 characters.", isDarkTheme: true)
            return
        }
        if name.containsWhitespace {
            AppHUD.error("username should not have white spaces", isDarkTheme: true)
            return
        }
        
        for char in name {
            if !legalCharSet.contains(char) {
                AppHUD.error("Invalid charaters found. Please use numbers, alphabets, dash and underscore", isDarkTheme: true)
                return
            }
        }
        
        AppHUD.progress(nil, isDarkTheme: true)
        
        guard let uid = uid else { return }
        let childUpdates = ["/\(USERS_NODE)/\(uid)/username": name,
                            "/usernames/\(name)": uid] as [String : Any]
        print("************************debugging", childUpdates)
        Database.database().reference().updateChildValues(childUpdates) { (err, ref) in
            if let err = err {
                AppHUD.progressHidden()
                AppHUD.error(err.localizedDescription + "\nThe username is already taken", isDarkTheme: true)
                return
            }
            AppHUD.progressHidden()
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
            mainTabBarController.setupViewControllers()
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func handleTextInputChange() {
        let color = UIColor.hexStringToUIColor(hex: "#CE93D8")
        let usernameCount = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
        if usernameCount > 2 && usernameCount < 16 {
            usernameTextField.border.backgroundColor = color.cgColor
            submitButton.backgroundColor = color
            submitButton.setTitleColor(.white, for: .normal)
            submitButton.isEnabled = true
        } else {
            usernameTextField.border.backgroundColor = UIColor.lightGray.cgColor
            submitButton.backgroundColor = UIColor.lightGray
            submitButton.setTitleColor(.white, for: .normal)
            submitButton.isEnabled = false
        }
    }
    
    fileprivate func setupViews() {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 20
        container.layer.masksToBounds = true
        
        
        container.addSubview(chooseUserNameLabel)
        container.addSubview(usernameTextField)
        container.addSubview(submitButton)
        
        
        view.addSubview(container)
        
        container.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 70, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 200)
        chooseUserNameLabel.anchor(top: container.topAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        chooseUserNameLabel.backgroundColor = UIColor.hexStringToUIColor(hex: "#CE93D8")
        usernameTextField.anchor(top: chooseUserNameLabel.bottomAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
        usernameTextField.layoutIfNeeded()
        usernameTextField.setupView()
        submitButton.anchor(top: usernameTextField.bottomAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 40)
        
        
        let shadowView = UIView()
        shadowView.backgroundColor = UIColor.white
        shadowView.layer.shadowOffset = CGSize(width: 1, height: 1)
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowRadius = 20.0
        shadowView.layer.cornerRadius = 20.0
        shadowView.layer.shadowColor = UIColor.black.cgColor
        
        view.insertSubview(shadowView, at: 0)
        shadowView.anchor(top: container.topAnchor, left: container.leftAnchor, bottom: container.bottomAnchor, right: container.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleUpdateUsername()
        return true
    }
}



