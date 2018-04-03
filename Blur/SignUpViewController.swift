import UIKit
import Firebase
import FontAwesome_swift

class SignUpViewController: UIViewController {
    
    let emailTextField: AppTextField = {
        let tf = AppTextField()
        tf.placeholder = "Email"
        tf.clearButtonMode = .whileEditing
        tf.autocorrectionType = .no
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.returnKeyType = .next
        tf.font = TEXT_FONT
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: AppTextField = {
        let tf = AppTextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.font = TEXT_FONT
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let signUpButton : UIButton = {
        let bt = UIButton(type: .system)
        bt.setTitle("Sign up", for: .normal)
        bt.setTitleColor(.white, for: .normal)
        bt.titleLabel?.font = BOLD_FONT
        bt.backgroundColor = .lightGray
        bt.layer.cornerRadius = 22
        bt.isEnabled = false
        bt.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return bt
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationItem.title = "Sign up"

        setupInputFields()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    fileprivate func setupInputFields() {
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signUpButton)
        
        emailTextField.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
        emailTextField.layoutIfNeeded()
        emailTextField.setupView()
        
        
        passwordTextField.anchor(top: emailTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
        passwordTextField.layoutIfNeeded()
        passwordTextField.setupView()
        
        signUpButton.anchor(top: passwordTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 44)

        let _ = UIView.createShadow(for: signUpButton, superview: view)
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
        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        AppHUD.progress(nil,  isDarkTheme: true)
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if let error = error {
                self.processSignUpError(error: error)
                return
            }
            guard let uid = user?.uid else { return }
            let fcmToken = Messaging.messaging().fcmToken
            let time = Date().timeIntervalSince1970
            let childUpdates = ["/\(FRIENDS_NODE)/\(uid)/\(uid)": ["status": FriendStatus.added.rawValue, "updatedTime": time],
                                "/\(USERS_NODE)/\(uid)": ["createdTime": time, "fcmToken": fcmToken ?? ""]] as [String : Any]
            Database.database().reference().updateChildValues(childUpdates, withCompletionBlock: { (error, ref) in
                if let error = error  {
                    self.processSignUpError(error: error)
                    return
                }
                AppHUD.progressHidden()
                let chooseNameController = ChooseUserNameController()
                chooseNameController.uid = uid
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.pushViewController(chooseNameController, animated: true)
            })
        })
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
            signUpButton.setTitleColor(.black, for: .normal)
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.lightGray
            signUpButton.setTitleColor(.white, for: .normal)
            emailTextField.border.backgroundColor = BACKGROUND_GRAY.cgColor
            passwordTextField.border.backgroundColor = BACKGROUND_GRAY.cgColor
        }
    }

}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if emailTextField == textField {
            passwordTextField.becomeFirstResponder()
        } 
        return true
    }
}
