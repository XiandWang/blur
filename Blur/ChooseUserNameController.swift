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
    private let legalChars = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-_")
    var uid: String?
    private let legalCharSet = Set(Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-_"))
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.clearButtonMode = .whileEditing
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.keyboardType = .alphabet
        tf.returnKeyType = .done
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = UITextBorderStyle.roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return tf
    }()
    
    let chooseUserNameLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Choose Username"
        lb.font = UIFont.boldSystemFont(ofSize: 20)
        lb.textAlignment = .center
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    let usernameDescriptionLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Username is your unique identifier in Hidingchat"
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
        bt.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        bt.setTitleColor(.white, for: .normal)
        
        bt.layer.cornerRadius = 20
        bt.layer.masksToBounds = true
        bt.addTarget(self, action: #selector(handleUpdateUsername), for: .touchUpInside)
        return bt
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        usernameTextField.delegate = self
        setupViews()
        print(legalChars.count, legalChars)
        usernameTextField.becomeFirstResponder()
    }
    
    @objc func handleUpdateUsername() {
        guard let name = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), name.count < 15 && name.count > 2 else {
            AppHUD.error("username should have more than 2 characters and less than 15 characters.", isDarkTheme: true)
            return
        }
        if name.containsWhitespace {
            AppHUD.error("username should not have white spaces", isDarkTheme: true)
            return
        }
        
        for char in name {
            if !legalCharSet.contains(char) {
                AppHUD.error("Invalid charaters found. Please use alphabets, dash and underscore", isDarkTheme: true)
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
        let usernameCount = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
        if usernameCount > 2 && usernameCount < 15 {
            submitButton.backgroundColor = YELLOW_COLOR
            submitButton.setTitleColor(.black, for: .normal)
            submitButton.isEnabled = true
        } else {
            submitButton.backgroundColor = UIColor.lightGray
            submitButton.setTitleColor(.white, for: .normal)
            submitButton.isEnabled = false
        }
    }
    
    fileprivate func setupViews() {
        let stackView = UIStackView(arrangedSubviews: [chooseUserNameLabel, usernameTextField, submitButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        view.addSubview(stackView)
        stackView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 50, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 150)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("return is entered")
        handleUpdateUsername()
        return true
    }
}



