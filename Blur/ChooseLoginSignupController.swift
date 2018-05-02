//
//  ChooseLoginSignupController.swift
//  Blur
//
//  Created by xiandong wang on 3/1/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import AZDialogView

class ChooseLoginSignupController: UIViewController, FBSDKLoginButtonDelegate, InviteDelegate {
    let hasPassedQuestions = "hasPassedQuestions"
    
    func invitesDidSend(_ controller: UIViewController) {
        UserDefaults.standard.set(true, forKey: self.hasPassedQuestions)
        AppHUD.success("Please sign up.", isDarkTheme: true)
    }
    
    func invitesDidCancel(_ controller: UIViewController) {
        AppHUD.error("Sorry, HidingChat might not be the right app for you. Feel free to delete it 😜.", isDarkTheme: true)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        if UserDefaults.standard.bool(forKey: self.hasPassedQuestions) {
            AppHUD.progress(nil, isDarkTheme: true)
            return true
        } else {
            self.showQuestionDialog()
            return false
        }
    }
    
    var isShowingEdited = true
    var timer: Timer?
    
    let editedImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "hiding-monkey-128")
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 50
        iv.backgroundColor = .clear
        return iv
    }()
    
    let originalImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "show-monkey-128")
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 50
        iv.backgroundColor = .clear
        return iv
    }()

    let loginButton: UIButton = {
        let bt = UIButton(type: .system)
        bt.backgroundColor = YELLOW_COLOR
        bt.setTitle("Log in", for: .normal)
        bt.titleLabel?.font = BOLD_FONT
        bt.setTitleColor(.black, for: .normal)
        bt.layer.cornerRadius = 22
        bt.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return bt
    }()
    
    let signUpButton : UIButton = {
        let bt = UIButton(type: .system)
        bt.setTitle("Sign up for free", for: .normal)
        bt.setTitleColor(.black, for: .normal)
        bt.titleLabel?.font = BOLD_FONT
        bt.backgroundColor = YELLOW_COLOR
        bt.layer.cornerRadius = 22
        bt.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return bt
    }()
    
    let dividerLabel: UILabel = {
        let lb = UILabel()
        lb.text = "----- or -----"
        lb.font = SMALL_TEXT_FONT
        lb.textAlignment = .center
        lb.textColor = .lightGray
        return lb
    }()
    
    let googleSignUpButton: UIButton = {
        let bt = UIButton(type: .system)
        bt.setTitle("Log in with Google", for: .normal)
        bt.setTitleColor(.white, for: .normal)
        bt.titleLabel?.font = BOLD_FONT
        bt.backgroundColor = GOOGLE_COLOR
        bt.layer.cornerRadius = 22
        bt.addTarget(self, action: #selector(handleGoogleSignUp), for: .touchUpInside)
        return bt
    }()
    
    lazy var facebookButton: FBSDKLoginButton = {
        let bt = FBSDKLoginButton()
        bt.delegate = self
        bt.titleLabel?.font = BOLD_FONT
        bt.setTitle("Log in with Facebook", for: UIControlState())
        bt.layer.cornerRadius = 22
        bt.clipsToBounds = true
        bt.setImage(nil, for: UIControlState())
        return bt
    }()
    
    func showQuestionDialog() {
        let dialog = AZDialogViewController(title: "Question: Are you a fun person?", message: "(HidingChat, like Snapchat, is for fun and teasing 😜)", titleFontSize: 22, messageFontSize: 16, buttonsHeight: 50, cancelButtonHeight: 50)
        dialog.blurBackground = false
        dialog.buttonStyle = { (button,height,position) in
            button.setTitleColor(PURPLE_COLOR, for: .normal)
            button.titleLabel?.font = TEXT_FONT
            button.layer.masksToBounds = true
            button.layer.borderColor = PURPLE_COLOR.cgColor
            button.backgroundColor = UIColor.white
        }
        dialog.dismissWithOutsideTouch = false
        dialog.addAction(AZDialogAction(title: "Yes", handler: { (dialog) -> (Void) in
            self.showTryNewThingsQuestion(dialog: dialog)
        }))
        dialog.addAction(AZDialogAction(title: "No", handler: { (dialog) -> (Void) in
            dialog.dismiss(animated: true, completion: {
                AppHUD.error("Sorry, HidingChat might not be the right app for you. Feel free to delete it 😜.", isDarkTheme: true)
            })
        }))
        dialog.show(in: self)
    }
    
    func showTryNewThingsQuestion(dialog: AZDialogViewController) {
        dialog.title = "Do you like trying new things?"
        dialog.message = "(HidingChat is a new app in the market ♥️.)"
        dialog.removeAllActions()
        dialog.addAction(AZDialogAction(title: "Yes", handler: { (dialog) -> (Void) in
            self.showInviteQuestions(dialog: dialog)
        }))
        dialog.addAction(AZDialogAction(title: "No", handler: { (dialog) -> (Void) in
            dialog.dismiss(animated: true, completion: {
                AppHUD.error("Sorry, HidingChat might not be the right app for you. Feel free to delete it 😜.", isDarkTheme: true)
            })
        }))
    }
    
    func showInviteQuestions(dialog: AZDialogViewController) {
        dialog.title = "Do you have a boyfriend/girlfriend/or friends to share fun photos?"
        dialog.message = "(HidingChat, like Snapchat, is sharing and sending photos 😜.)"
        dialog.removeAllActions()
        dialog.addAction(AZDialogAction(title: "Yes", handler: { (dialog) -> (Void) in
            let contacts = ContactsController()
            contacts.delegate = self
            contacts.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: contacts, action: #selector(contacts.handleDismiss))
            dialog.dismiss(animated: true, completion: {
                AppHUD.success("You will sign up after inviting your boyfriend/girlfriend/or friends ❤️.", isDarkTheme: true)
                self.present(UINavigationController(rootViewController: contacts), animated: true, completion: nil)
            })
        }))
        dialog.addAction(AZDialogAction(title: "No", handler: { (dialog) -> (Void) in
            dialog.dismiss(animated: true, completion: {
                AppHUD.error("Sorry, HidingChat might not be the right app for you. Feel free to delete it 😜.", isDarkTheme: true)
            })
        }))
        dialog.addAction(AZDialogAction(title: "I am invited", handler: { (dialog) -> (Void) in
            self.hideBackButton()
            let typeInviter = TypeInviterController()
            typeInviter.delegate = self
            self.navigationController?.pushViewController(typeInviter, animated: true)
            dialog.dismiss()
        }))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self

        view.backgroundColor = .white
        self.navigationItem.title = "HidingChat"
        self.setupNavTitleAttr()
        
        AnimationHelper.perspectiveTransform(for: view)
        originalImageView.layer.transform = AnimationHelper.yRotation(.pi / 2)
        
        setupImageViews()
        if let facebookButtonHeightConstraint = facebookButton.constraints.first(where: { $0.firstAttribute == .height }) {
            facebookButton.removeConstraint(facebookButtonHeightConstraint)
        }
        
        setupButtons()
        
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(handleRotate), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            AppHUD.progressHidden()
            AppHUD.error(error.localizedDescription, isDarkTheme: true)
            return
        }
        
        if result.isCancelled {
            AppHUD.progressHidden()
            return
        }
        
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                AppHUD.progressHidden()
                AppHUD.error(error.localizedDescription, isDarkTheme: true)
                return
            }
            guard let uid = user?.uid else { return }
            Database.database().reference().child(USERS_NODE).child(uid).observeSingleEvent(of: .value, with: { (snap) in
                if !snap.exists() {
                    let fcmToken = Messaging.messaging().fcmToken
                    let time = Date().timeIntervalSince1970
                    let childUpdates = ["/\(FRIENDS_NODE)/\(uid)/\(uid)": ["status": FriendStatus.added.rawValue, "updatedTime": time],
                                        "/\(FRIENDS_NODE)/\(uid)/\(FIRRef.getTeamUid())": ["status": FriendStatus.added.rawValue, "updatedTime": time],
                                        "/\(FRIENDS_NODE)/\(FIRRef.getTeamUid())/\(uid)": ["status": FriendStatus.added.rawValue, "updatedTime": time],
                                        "/\(USERS_NODE)/\(uid)": ["createdTime": time, "fcmToken": fcmToken ?? ""]] as [String : Any]
                    Database.database().reference().updateChildValues(childUpdates, withCompletionBlock: { (error, ref) in
                        if let error = error  {
                            AppHUD.progressHidden()
                            AppHUD.error(error.localizedDescription, isDarkTheme: true)
                            return
                        }
                        NotificationCenter.default.post(name: NEW_GOOGLE_SIGN_UP_SUCCESS, object: nil, userInfo: ["userId": uid])
                    })
                } else {
                    NotificationCenter.default.post(name: GOOGLE_LOGIN_SUCCESS, object: nil, userInfo: ["userId": uid])
                }
            })
        }
    }
    
    fileprivate func setupImageViews() {
        view.addSubview(originalImageView)
        view.addSubview(editedImageView)

        originalImageView.anchor(top: self.topLayoutGuide.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 50, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        originalImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        editedImageView.anchor(top: originalImageView.topAnchor, left: originalImageView.leftAnchor, bottom: originalImageView.bottomAnchor, right: originalImageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    fileprivate func setupButtons() {
        view.addSubview(loginButton)
        view.addSubview(signUpButton)
        view.addSubview(dividerLabel)
        view.addSubview(googleSignUpButton)
        view.addSubview(facebookButton)
        
        loginButton.anchor(top: view.centerYAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 44)
        signUpButton.anchor(top: loginButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 44)
        dividerLabel.anchor(top: signUpButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 5, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        googleSignUpButton.anchor(top: dividerLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 5, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 44)
        facebookButton.anchor(top: googleSignUpButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 44)
        dividerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let _ = UIView.createShadow(for: loginButton, superview: view, radius: 5)
        let _ = UIView.createShadow(for: signUpButton, superview: view, radius: 5)
        let _ = UIView.createShadow(for: googleSignUpButton, superview: view, radius: 5)
        let _ = UIView.createShadow(for: facebookButton, superview: view, radius: 5)
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewGoogleSignUpNotif(notification:)), name: NEW_GOOGLE_SIGN_UP_SUCCESS, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleGoogleLoginNotif), name: GOOGLE_LOGIN_SUCCESS, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        timer?.invalidate()
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
}

//MARK: actions
extension ChooseLoginSignupController {
    
    //MARK: Google Sign in
    @objc func handleGoogleSignUp() {
        if UserDefaults.standard.bool(forKey: self.hasPassedQuestions) {
            AppHUD.progress("Connecting to Google...", isDarkTheme: true)
            GIDSignIn.sharedInstance().signIn()
        } else {
            self.showQuestionDialog()
        }
        
    }
    
    @objc func handleNewGoogleSignUpNotif(notification: NSNotification) {
        AppHUD.progressHidden()
        guard let userId = notification.userInfo?["userId"] as? String else { return }
        
        let chooseUserName = ChooseUserNameController()
        chooseUserName.uid = userId
        
        self.navigationController?.pushViewController(chooseUserName, animated: true)
    }
    
    @objc func handleGoogleLoginNotif() {
        AppHUD.progressHidden()
        guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
        mainTabBarController.setupViewControllers()
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Navigation
    @objc func handleShowSignUp() {
        if UserDefaults.standard.bool(forKey: self.hasPassedQuestions) {
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(SignUpViewController(), animated: true)
        } else {
            self.showQuestionDialog()
        }
    }
    
    @objc func handleShowLogin() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.pushViewController(LoginController(), animated: true)
    }
    
    //MARK: view animation
    @objc func handleRotate() {
        animateRotatingImage(toOriginal: isShowingEdited)
    }
}

extension ChooseLoginSignupController: GIDSignInUIDelegate {
}
