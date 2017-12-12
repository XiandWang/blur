//
//  ImageMessageController.swift
//  Blur
//
//  Created by xiandong wang on 11/4/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit
import Kingfisher

class ImageMessageController : UIViewController {
    var isShowingEdited = true
    
    var fromUser: User?
       
    
    var message: Message? {
        didSet {
            if let message = message {
                let editedUrl = URL(string: message.editedImageUrl)
                editedImageView.kf.indicatorType = .activity
                editedImageView.kf.setImage(with: editedUrl)
                
                let originalUrl = URL(string: message.originalImageUrl)
                originalImageView.kf.indicatorType = .activity
                originalImageView.kf.setImage(with: originalUrl)
            }
        }
    }
    
    var photoIndex : Int?
    
    let editedImageView : UIImageView = {
        let iv = UIImageView()
        iv.kf.indicatorType = .activity
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let originalImageView : UIImageView = {
        let iv = UIImageView()
        iv.kf.indicatorType = .activity
        iv.contentMode = .scaleAspectFit
        iv.isHidden = true
        return iv
    }()
    
    let showButton: UIButton = {
        let bt = UIButton(type: .custom)
        let size = CGSize(width: 44, height: 44)
        bt.setImage(UIImage.fontAwesomeIcon(name: .thumbsOUp, textColor: .white, size: size), for: .normal)
        bt.setTitle("Show", for: .normal)
        bt.backgroundColor = GREEN_COLOR
        
        bt.addTarget(self, action: #selector(handleShowOriginalImage), for: .touchUpInside)
        return bt
    }()
    
    let passButton: UIButton = {
        let bt = UIButton(type: .custom)
        let size = CGSize(width: 44, height: 44)
        bt.setImage(UIImage.fontAwesomeIcon(name: .thumbsODown, textColor: .white, size: size), for: .normal)
        bt.setTitle("Pass", for: .normal)
        bt.backgroundColor = PRIMARY_COLOR
        return bt
    }()
    
    let rotateImageButton: UIButton = {
        let bt = UIButton(type: .custom)
        let size = CGSize(width: 44, height: 44)
        bt.setImage(UIImage.fontAwesomeIcon(name: .undo, textColor: .white, size: size), for: .normal)
        
        bt.addTarget(self, action: #selector(handleRotateImage), for: .touchUpInside)
        return bt
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        view.addSubview(originalImageView)
        view.addSubview(editedImageView)
        setupConstraints()
        setupButtonStackViews()
        AnimationHelper.perspectiveTransform(for: view)
        originalImageView.layer.transform = AnimationHelper.yRotation(.pi / 2)
    }
    
    fileprivate func setupButtonStackViews() {
        let stackView = UIStackView(arrangedSubviews: [showButton, passButton])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        view.addSubview(stackView)

        stackView.anchor(top: nil, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 48)
    }
    
    fileprivate func setupConstraints() {
        editedImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        originalImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func handleRotateImage() {
        if isShowingEdited {
            animateRotatingImage(toOriginal: true)
            UIView.animateKeyframes(withDuration: 2.0, delay: 0, options: .calculationModeCubic, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1, animations: {
                    self.rotateImageButton.layer.transform = CATransform3DIdentity
                })
            }, completion: nil)
        } else {
            animateRotatingImage(toOriginal: false)
            UIView.animateKeyframes(withDuration: 2.0, delay: 0, options: .calculationModeCubic, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1, animations: {
                    self.rotateImageButton.layer.transform = AnimationHelper.zRotation(.pi)
                })
            }, completion: nil)
        }
    }
    
    fileprivate func animateRotatingImage(toOriginal: Bool) {
        if toOriginal {
            isShowingEdited = false
            UIView.animateKeyframes(
                withDuration: 2.0,
                delay: 0,
                options: .calculationModeCubic,
                animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/2) {
                        self.editedImageView.layer.transform = AnimationHelper.yRotation(-.pi / 2)
                    }
                    UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2) {
                        self.originalImageView.layer.transform = AnimationHelper.yRotation(0.0)
                    }
            }, completion: nil)
        } else {
            isShowingEdited = true
            UIView.animateKeyframes(
                withDuration: 2.0,
                delay: 0,
                options: .calculationModeCubic,
                animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/2) {
                        self.originalImageView.layer.transform = AnimationHelper.yRotation(.pi / 2)
                    }
                    UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2) {
                        self.editedImageView.layer.transform = CATransform3DIdentity
                    }
            }, completion: nil)
        }
    }
}

extension ImageMessageController {
    func handleShowOriginalImage() {
        if let allowOrignal = message?.allowOrignal, allowOrignal {
            print("allowed")
            self.originalImageView.isHidden = false
            self.animateRotatingImage(toOriginal: true)
            UIView.animate(withDuration: 2.0, animations: {
                self.showButton.alpha = 0
                self.passButton.alpha = 0
            }, completion: { (_) in
                self.showButton.removeFromSuperview()
                self.passButton.removeFromSuperview()
                self.view.addSubview(self.rotateImageButton)
                self.rotateImageButton.anchor(top: nil, left: nil, bottom: self.view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 16, paddingRight: 0, width: 44, height: 44)
                self.rotateImageButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            })
        } else {
            print("not allowed")
        }
    }
}

struct AnimationHelper {
    static func yRotation(_ angle: Double) -> CATransform3D {
        return CATransform3DMakeRotation(CGFloat(angle), 0.0, 1.0, 0.0)
    }
    
    static func zRotation(_ angle: Double) -> CATransform3D {
        return CATransform3DMakeRotation(CGFloat(angle), 0.0, 0.0, 1.0)
    }
    
    static func perspectiveTransform(for containerView: UIView) {
        var transform = CATransform3DIdentity
        transform.m34 = -0.002
        containerView.layer.sublayerTransform = transform
    }
}
