import UIKit
import Firebase
import FontAwesome_swift

class SignUpViewController: UIViewController {
    
    let signUpLabel : UILabel = {
        let lb = UILabel()
        lb.text = "Sign up"
        lb.font = UIFont.boldSystemFont(ofSize: 20)
        lb.textAlignment = .center
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textColor = .black
        return lb
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.clearButtonMode = .whileEditing
        tf.autocorrectionType = .no
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.returnKeyType = .next
        
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle =  UITextBorderStyle.roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: AppTextField = {
        let tf = AppTextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true

        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle =  UITextBorderStyle.roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let signUpButton : UIButton = {
        let bt = UIButton(type: .system)
        bt.setTitle("Sign up", for: .normal)
        bt.setTitleColor(.black, for: .normal)
        bt.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        bt.backgroundColor = .lightGray
        bt.layer.cornerRadius = 25
        bt.layer.masksToBounds = true
        bt.isEnabled = false
        
        bt.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return bt
    }()
    
    let bottomLoginButton: UIButton = {
        let bt = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account? ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Login!", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: RED_COLOR
            ]))
        
        bt.setAttributedTitle(attributedTitle, for: .normal)
        return bt
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupInputFields()
        setupLoginButton()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    fileprivate func setupLoginButton() {
        view.addSubview(bottomLoginButton)
        bottomLoginButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        bottomLoginButton.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
    }
    
    fileprivate func setupInputFields() {
        let stackView = UIStackView(arrangedSubviews: [signUpLabel, emailTextField, passwordTextField, signUpButton])
        
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        view.addSubview(stackView)
        stackView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 220)
    }
}

// MARK: - Actions
extension SignUpViewController {
    @objc func handleSignUp() {
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            email != ""  && password != "" else { return }
        
        signUpButton.setTitle("Signing up...", for: .normal)
        signUpButton.isEnabled = false
        AppHUD.progress(nil,  isDarkTheme: true)
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if let error = error {
                self.processSignUpError(error: error)
                return
            }
            guard let uid = user?.uid else { return }
            guard let fcmToken = Messaging.messaging().fcmToken else {
                AppHUD.error("fcm Token error", isDarkTheme: true)
                return
            }
            let time = Date().timeIntervalSince1970
            let childUpdates = ["/\(FRIENDS_NODE)/\(uid)/\(uid)": ["status": FriendStatus.added.rawValue, "updatedTime": time],
                        
                                "/\(USERS_NODE)/\(uid)": ["createdTime": time, "fcmToken": fcmToken]] as [String : Any]
            Database.database().reference().updateChildValues(childUpdates, withCompletionBlock: { (error, ref) in
                if let error = error  {
                    self.processSignUpError(error: error)
                    return
                }
                AppHUD.progressHidden()
                AppHUD.success("Thank you", isDarkTheme: false)
                let chooseNameController = ChooseUserNameController()
                chooseNameController.uid = uid
                self.navigationController?.pushViewController(chooseNameController, animated: true)
            })
        })
    }
    
    @objc func handleShowLogin() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    fileprivate func processSignUpError(error: Error) {
        AppHUD.progressHidden()
        AppHUD.error(error.localizedDescription,  isDarkTheme: true)
        self.signUpButton.setTitle("Sign up", for: .normal)
        self.signUpButton.isEnabled = true
    }
    
    @objc func handleTextInputChange() {
        let isEmailValid = emailTextField.text?.count ?? 0 > 0
        let isPasswordValid = passwordTextField.text?.count ?? 0 > 0
        if isEmailValid && isPasswordValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = YELLOW_COLOR
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.lightGray
        }
    }

}

extension SignUpViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if emailTextField == textField {
            passwordTextField.becomeFirstResponder()
        } 
        return true
    }
}
