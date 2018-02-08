import UIKit
import Firebase
import FontAwesome_swift

class SignUpViewController: UIViewController {
    var isShowingEdited = true
    var timer: Timer?
    
    let editedImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "love_half")
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 50
        
        return iv
    }()
    
    let originalImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "love")
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 50
        
        return iv
    }()
    
    let signUpLabel : UILabel = {
        let lb = UILabel()
        lb.text = "Hidingchat Sign up"
        lb.font = UIFont.boldSystemFont(ofSize: 20)

        lb.textAlignment = .center
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textColor = .white
        return lb
    }()
    
    let emailTextField: AppTextField = {
        let tf = AppTextField()
        tf.placeholder = "Email"
        tf.clearButtonMode = .whileEditing
        tf.autocorrectionType = .no
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.returnKeyType = .next
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: AppTextField = {
        let tf = AppTextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let signUpButton : UIButton = {
        let bt = UIButton(type: .system)
        bt.setTitle("Sign up", for: .normal)
        bt.setTitleColor(.white, for: .normal)
        bt.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        bt.backgroundColor = .lightGray
        bt.layer.cornerRadius = 20
        bt.isEnabled = false
        
        bt.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return bt
    }()
    
    let bottomLoginButton: UIButton = {
        let bt = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Go to ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Login", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: PURPLE_COLOR
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
        
        AnimationHelper.perspectiveTransform(for: view)
        originalImageView.layer.transform = AnimationHelper.yRotation(.pi / 2)
 
        timer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(handleRotate), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    deinit {
        print("Sign up deinit")
        timer?.invalidate()
    }
    
    @objc func handleRotate() {
         animateRotatingImage(toOriginal: isShowingEdited)
    }
    
    fileprivate func animateRotatingImage(toOriginal: Bool) {
        if toOriginal {
            UIView.animateKeyframes(
                withDuration: 2.0, delay: 0, options: .calculationModeCubic,
                animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/2) {
                        self.editedImageView.layer.transform = AnimationHelper.yRotation(-.pi / 2)
                    }
                    UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2) {
                        self.originalImageView.layer.transform = AnimationHelper.yRotation(0.0)
                    }
                    
            }, completion: { (bool) in
                if bool {
                    self.isShowingEdited = false
                }
            })
        } else {
            UIView.animateKeyframes(
                withDuration: 2.0, delay: 0, options: .calculationModeCubic,
                animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/2) {
                        self.originalImageView.layer.transform = AnimationHelper.yRotation(.pi / 2)
                        
                    }
                    UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2) {
                        self.editedImageView.layer.transform = CATransform3DIdentity
                    }
            }, completion: { (bool) in
                if bool {
                    self.isShowingEdited = true
                }
            })
        }
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
        view.addSubview(originalImageView)
        originalImageView.anchor(top: self.topLayoutGuide.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        originalImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        view.addSubview(editedImageView)
        editedImageView.anchor(top: originalImageView.topAnchor, left: originalImageView.leftAnchor, bottom: originalImageView.bottomAnchor, right: originalImageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 20
        container.layer.masksToBounds = true
    
        container.addSubview(signUpLabel)
        container.addSubview(emailTextField)
        container.addSubview(passwordTextField)
        container.addSubview(signUpButton)
        view.addSubview(container)
        
        container.anchor(top: editedImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 250)
        signUpLabel.anchor(top: container.topAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        signUpLabel.backgroundColor = PURPLE_COLOR_LIGHT
        emailTextField.anchor(top: signUpLabel.bottomAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
        emailTextField.layoutIfNeeded()
        emailTextField.setupView()
        passwordTextField.anchor(top: emailTextField.bottomAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
        passwordTextField.layoutIfNeeded()
        passwordTextField.setupView()
        signUpButton.anchor(top: passwordTextField.bottomAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 40)
        
        UIView.createShadow(for: container, superview: view)
    }
}

extension UIView {
    static func createShadow(for containerView: UIView, superview: UIView) {
        let shadowView = UIView()
        shadowView.backgroundColor = UIColor.white
        shadowView.layer.shadowOffset = CGSize(width: 1, height: 1)
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowRadius = 20.0
        shadowView.layer.cornerRadius = 20.0
        shadowView.layer.shadowColor = UIColor.black.cgColor
        
        superview.insertSubview(shadowView, at: 0)
        shadowView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
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
            signUpButton.backgroundColor = PURPLE_COLOR_LIGHT
            emailTextField.border.backgroundColor = PURPLE_COLOR_LIGHT.cgColor
            passwordTextField.border.backgroundColor = PURPLE_COLOR_LIGHT.cgColor
            signUpButton.setTitleColor(.white, for: .normal)
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.lightGray
            emailTextField.border.backgroundColor = BACKGROUND_GRAY.cgColor
            passwordTextField.border.backgroundColor = BACKGROUND_GRAY.cgColor
            signUpButton.setTitleColor(.white, for: .normal)
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
