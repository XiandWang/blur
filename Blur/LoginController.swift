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
        lb.text = "Log In"
        lb.font = UIFont.boldSystemFont(ofSize: 20)
        lb.textAlignment = .center
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textColor = .black
        return lb
    }()
    
    let dontHaveAccountButton: UIButton = {
        let bt = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14), NSForegroundColorAttributeName: PRIMARY_COLOR]))
        
        bt.setAttributedTitle(attributedTitle, for: .normal)
        return bt
    }()
    
    let emailTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email: "
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
        tf.borderStyle = UITextBorderStyle.roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let loginButton: UIButton = {
        let bt = UIButton(type: .system)
        bt.setTitle("Login", for: .normal)
        bt.backgroundColor = PRIMARY_COLOR_LIGHT
        bt.layer.cornerRadius = 5
        bt.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        bt.setTitleColor(.black, for: .normal)
        bt.isEnabled = false
        bt.layer.cornerRadius = 20
        bt.layer.masksToBounds = true
        bt.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return bt
    }()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func handleLogin() {
        FIRAuth.auth()?.signIn(withEmail: emailTextField.text!, password: passWordTextField.text!, completion: { (user, err) in
            if let err = err {
                AppHUD.error("Login failed. Please check your email and password retry again.")
                print("Failed to login", err.localizedDescription)
                return
            }
            
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
            //mainTabBarController.setupViewControllers()
            self.dismiss(animated: true, completion: nil)
            
        })
        
    }
    
    func handleTextInputChange() {
        let isEmailValid = emailTextField.text?.characters.count ?? 0 > 0
        let isPasswdValid = passWordTextField.text?.characters.count ?? 0 > 0
        if isEmailValid && isPasswdValid {
            loginButton.backgroundColor = PRIMARY_COLOR
            loginButton.isEnabled = true
        } else {
            loginButton.backgroundColor = PRIMARY_COLOR_LIGHT
            loginButton.isEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        dontHaveAccountButton.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        view.backgroundColor = .white
        
        setupInputView()
        emailTextField.delegate = self
        passWordTextField.delegate = self
    }
    
    func setupInputView() {
        let stackView = UIStackView(arrangedSubviews: [loginLabel, emailTextField, passWordTextField, loginButton])
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = UIStackViewDistribution.fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40).isActive = true
        stackView.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 190)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func handleShowSignUp() {
        let signupController = ViewController()
        navigationController?.pushViewController(signupController, animated: true)
    }
}

extension LoginController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            print("dfsdsd")
            passWordTextField.becomeFirstResponder()
        } else if textField == passWordTextField {
            textField.resignFirstResponder()
        }
        print("************************debugging")
        return true
    }
}

