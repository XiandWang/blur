//
//  LoginController.swift
//  Blur
//
//  Created by xiandong wang on 7/10/17.
//  Copyright © 2017 xiandong wang. All rights reserved.

import UIKit
import Firebase

class LoginController: UIViewController {
    
    let emailTextField : AppTextField = {
        let tf = AppTextField()
        tf.placeholder = "Email: "
        tf.clearButtonMode = .whileEditing
        tf.autocorrectionType = .no
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.returnKeyType = .next
        tf.font = TEXT_FONT
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        return tf
    }()
    
    let passwordTextField : AppTextField = {
        let tf = AppTextField()
        tf.placeholder = "Password: "
        tf.font = TEXT_FONT
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let loginButton: UIButton = {
        let bt = UIButton(type: .system)
        bt.backgroundColor = .lightGray
        bt.setTitle("Login", for: .normal)
        bt.titleLabel?.font = BOLD_FONT
        bt.setTitleColor(.white, for: .normal)
        bt.isEnabled = false
        bt.layer.cornerRadius = 22
        bt.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return bt
    }()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Login"

        view.backgroundColor = .white
        setupInputView()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    
    fileprivate func setupInputView() {
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        
        emailTextField.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
        emailTextField.layoutIfNeeded()
        emailTextField.setupView()
        passwordTextField.anchor(top: emailTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
        passwordTextField.layoutIfNeeded()
        passwordTextField.setupView()
        loginButton.anchor(top: passwordTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 44)
        
        let _ = UIView.createShadow(for: loginButton, superview: view)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// mark actions
extension LoginController {
    @objc func handleLogin() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        AppHUD.progress(nil,  isDarkTheme: true)
        self.loginButton.isEnabled = false
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, err) in
            if let _ = err {
                AppHUD.progressHidden()
                AppHUD.error("Login failed. Please check your email and password.",  isDarkTheme: true)
                self.loginButton.isEnabled = true
                return
            }
            AppHUD.progressHidden()
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
            mainTabBarController.setupViewControllers()
            self.dismiss(animated: true, completion: nil)
        })
    }

    @objc func handleTextInputChange() {
        let isEmailValid = emailTextField.text?.count ?? 0 > 0
        let isPasswdValid = passwordTextField.text?.count ?? 0 > 0
        if isEmailValid && isPasswdValid {
            loginButton.backgroundColor = YELLOW_COLOR
            loginButton.setTitleColor(.black, for: .normal)
            loginButton.isEnabled = true
        } else {
            loginButton.backgroundColor = UIColor.lightGray
            loginButton.setTitleColor(.white, for: .normal)
            loginButton.isEnabled = false
        }
    }
}

// MARK: UITextFieldDelegate
extension LoginController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
        }
        return true
    }
}

