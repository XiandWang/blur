//
//  ChooseUserNameController.swift
//  Blur
//
//  Created by xiandong wang on 12/2/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit
import Firebase

class ChooseUserNameController: UIViewController {
    
    var uid: String?
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.clearButtonMode = .whileEditing
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.returnKeyType = .done
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle =  UITextBorderStyle.roundedRect
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
        setupViews()
    }
    
    func handleUpdateUsername() {
        guard let name = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), name.count < 15 && name.count > 2 else {
            AppHUD.error("username should have more than 2 characters and less than 15 characters.")
            return
        }
        if name.containsWhitespace {
            AppHUD.error("username should not have white spaces")
        }
        
        AppHUD.progress(nil)
        
        guard let uid = uid else { return }
        let childUpdates = [
                            "/\(USERS_NODE)/\(uid)": ["username": name, "createdTime": Date().timeIntervalSince1970],
                            "/usernames/\(name)": uid
                            ] as [String : Any]
        Database.database().reference().updateChildValues(childUpdates) { (err, ref) in
            if let err = err {
                AppHUD.progressHidden()
                AppHUD.error(err.localizedDescription)
                return
            }
            AppHUD.progressHidden()
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
            mainTabBarController.setupViewControllers()
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func handleTextInputChange() {
        let usernameCount = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
        if usernameCount > 2 && usernameCount < 15 {
            submitButton.backgroundColor = PRIMARY_COLOR
            submitButton.isEnabled = true
        } else {
            submitButton.backgroundColor = UIColor.lightGray
            submitButton.isEnabled = false
        }
    }
    
    fileprivate func setupViews() {
        let stackView = UIStackView(arrangedSubviews: [chooseUserNameLabel, usernameTextField, submitButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        view.addSubview(stackView)
        stackView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 150)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
