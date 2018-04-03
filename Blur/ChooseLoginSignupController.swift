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

class ChooseLoginSignupController: UIViewController {
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
        bt.setTitle("Login", for: .normal)
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
        bt.setTitle("Login with Google", for: .normal)
        bt.setTitleColor(.white, for: .normal)
        bt.titleLabel?.font = BOLD_FONT
        bt.backgroundColor = GOOGLE_COLOR
        bt.layer.cornerRadius = 22
        bt.addTarget(self, action: #selector(handleGoogleSignUp), for: .touchUpInside)
        return bt
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self

        view.backgroundColor = .white
        self.navigationItem.title = "HidingChat"
        self.setupNavTitleAttr()
        
        AnimationHelper.perspectiveTransform(for: view)
        originalImageView.layer.transform = AnimationHelper.yRotation(.pi / 2)
        
        setupImageViews()
        setupButtons()
        
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(handleRotate), userInfo: nil, repeats: true)
        timer?.fire()
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
        
        loginButton.anchor(top: view.centerYAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 44)
        signUpButton.anchor(top: loginButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 44)
        dividerLabel.anchor(top: signUpButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 5, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        googleSignUpButton.anchor(top: dividerLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 5, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 44)
        dividerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let _ = UIView.createShadow(for: loginButton, superview: view, radius: 5)
        let _ = UIView.createShadow(for: signUpButton, superview: view, radius: 5)
        let _ = UIView.createShadow(for: googleSignUpButton, superview: view, radius: 5)
        
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
        AppHUD.progress("Connecting to Google...", isDarkTheme: true)
        GIDSignIn.sharedInstance().signIn()
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
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.pushViewController(SignUpViewController(), animated: true)
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
