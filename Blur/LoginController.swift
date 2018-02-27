//
//  LoginController.swift
//  Blur
//
//  Created by xiandong wang on 7/10/17.
//  Copyright © 2017 xiandong wang. All rights reserved.

import UIKit
import Firebase


class LoginController: UIViewController {
    
    let loginLabel : UILabel = {
        let lb = UILabel()
        lb.text = "Login"
        lb.font = UIFont.boldSystemFont(ofSize: 20)
        lb.textAlignment = .center
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textColor = .black
        return lb
    }()
    
    let dontHaveAccountButton: UIButton = {
        let bt = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Go to ", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: YELLOW_COLOR]))
        
        bt.setAttributedTitle(attributedTitle, for: .normal)
        return bt
    }()
    
    let emailTextField : AppTextField = {
        let tf = AppTextField()
        tf.placeholder = "Email: "
        tf.clearButtonMode = .whileEditing
        tf.autocorrectionType = .no
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.returnKeyType = .next
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        return tf
    }()
    
    let passwordTextField : AppTextField = {
        let tf = AppTextField()
        tf.placeholder = "Password: "
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let loginButton: UIButton = {
        let bt = UIButton(type: .system)
        bt.backgroundColor = .lightGray
        bt.setTitle("Login", for: .normal)
        bt.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
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
        navigationController?.isNavigationBarHidden = true

        view.backgroundColor = .white
        setupDontHaveAccountButton()
        setupInputView()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    fileprivate func setupDontHaveAccountButton() {
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        dontHaveAccountButton.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
    }
    
    fileprivate func setupInputView() {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 20
        container.layer.masksToBounds = true
        
        container.addSubview(loginLabel)
        container.addSubview(emailTextField)
        container.addSubview(passwordTextField)
        container.addSubview(loginButton)
        view.addSubview(container)
        
        container.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 70, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 250)
        loginLabel.anchor(top: container.topAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        loginLabel.backgroundColor = YELLOW_COLOR
        emailTextField.anchor(top: loginLabel.bottomAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
        emailTextField.layoutIfNeeded()
        emailTextField.setupView()
        passwordTextField.anchor(top: emailTextField.bottomAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
        passwordTextField.layoutIfNeeded()
        passwordTextField.setupView()
        loginButton.anchor(top: passwordTextField.bottomAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 44)
        
        let _ = UIView.createShadow(for: container, superview: view)
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
            
//            Database.isUsernameChosen(uid: uid, completion: { (isChosen, userNameError) in
//                if let userNameError = userNameError {
//                    AppHUD.error(userNameError.localizedDescription, isDarkTheme: true)
//                    return
//                }
//                if isChosen {
//                    
//                } else {
//                    let chooseNameController = ChooseUserNameController()
//                    chooseNameController.uid = uid
//                    self.navigationController?.pushViewController(chooseNameController, animated: true)
//                }
//            })
        })
    }

    @objc func handleShowSignUp() {
        let signupController = SignUpViewController()
        navigationController?.pushViewController(signupController, animated: true)
    }
    
    @objc func handleTextInputChange() {
        let isEmailValid = emailTextField.text?.count ?? 0 > 0
        let isPasswdValid = passwordTextField.text?.count ?? 0 > 0
        if isEmailValid && isPasswdValid {
            loginButton.backgroundColor = YELLOW_COLOR
            loginButton.setTitleColor(.black, for: .normal)
            loginButton.isEnabled = true
        } else {
            emailTextField.border.backgroundColor = BACKGROUND_GRAY.cgColor
            passwordTextField.border.backgroundColor = BACKGROUND_GRAY.cgColor
            loginButton.backgroundColor = UIColor.lightGray
            loginButton.setTitleColor(.white, for: .normal)
            loginButton.isEnabled = false
        }
    }
}

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

