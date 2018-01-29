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
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: RED_COLOR]))
        
        bt.setAttributedTitle(attributedTitle, for: .normal)
        return bt
    }()
    
    let emailTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email: "
        tf.clearButtonMode = .whileEditing
        tf.autocorrectionType = .no
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.returnKeyType = .next
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = UITextBorderStyle.roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        return tf
    }()
    
    let passWordTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password: "
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
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
        bt.layer.cornerRadius = 25
        bt.layer.masksToBounds = true
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
        passWordTextField.delegate = self
    }
    
    fileprivate func setupDontHaveAccountButton() {
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        dontHaveAccountButton.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
    }
    
    fileprivate func setupInputView() {
        let stackView = UIStackView(arrangedSubviews: [loginLabel, emailTextField, passWordTextField, loginButton])
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = UIStackViewDistribution.fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        stackView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 220)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// mark actions
extension LoginController {
    @objc func handleLogin() {
        guard let email = emailTextField.text, let password = passWordTextField.text else { return }
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
            guard let uid = user?.uid else { return }
            
            Database.isUsernameChosen(uid: uid, completion: { (isChosen, userNameError) in
                if let userNameError = userNameError {
                    AppHUD.error(userNameError.localizedDescription, isDarkTheme: true)
                    return
                }
                if isChosen {
                    guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
                    mainTabBarController.setupViewControllers()
                    self.dismiss(animated: true, completion: nil)
                } else {
                    let chooseNameController = ChooseUserNameController()
                    chooseNameController.uid = uid
                    self.navigationController?.pushViewController(chooseNameController, animated: true)
                }
            })
        })
    }

    @objc func handleShowSignUp() {
        let signupController = SignUpViewController()
        navigationController?.pushViewController(signupController, animated: true)
    }
    
    @objc func handleTextInputChange() {
        let isEmailValid = emailTextField.text?.count ?? 0 > 0
        let isPasswdValid = passWordTextField.text?.count ?? 0 > 0
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

extension LoginController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passWordTextField.becomeFirstResponder()
        } else if textField == passWordTextField {
            textField.resignFirstResponder()
            handleLogin()
        }
        return true
    }
}

