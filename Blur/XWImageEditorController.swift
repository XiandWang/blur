//
//  XWImageEditorController.swift
//  TestTimer
//
//  Created by xiandong wang on 11/13/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit

class XWImageEditorController: UIViewController {
    let Text_Edit_Done_Notification = "TEXT_EDIT_DONE_NOTIFICATION"
    
    var userToSend: User?
    
    var imageView: UIImageView! //显示的图片
    var scrollView: UIScrollView!
    var menuView: UIView!        //底部工具
    
    var currentImage: UIImage
    var originalImage: UIImage
    
    let resetImageButton: UIButton = {
        let bt = UIButton(type: .custom)
        let size = CGSize(width: 44, height: 44)
        bt.setImage(UIImage.fontAwesomeIcon(name: .refresh, textColor: .black, size: size), for: .normal)
        bt.backgroundColor = .white
        bt.layer.cornerRadius = 25
        bt.layer.masksToBounds = true
        bt.layer.borderColor = YELLOW_COLOR.cgColor
        bt.layer.borderWidth = 1.0
        bt.alpha = 1.0
        bt.addTarget(self, action: #selector(handleResetImage), for: .touchUpInside)
        
        return bt
    }()
    
    var currentTool: XWImageToolBase?
    
    init(with image: UIImage, sendTo user: User) {
        currentImage = image.copy() as! UIImage
        originalImage = image.copy() as! UIImage
        userToSend = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        self.view.backgroundColor = XWImageEditorTheme.backgroundColor
        self.navigationItem.title = "Hide" //###
        self.initMenuView()
        self.initImageScrollView()
        self.initToolSettings()
        self.initNavigationBar()
        //self.setupButtons()
        
        
        if self.imageView == nil {
            self.imageView = UIImageView()
            self.scrollView.addSubview(self.imageView)
            self.refreshImageView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshImageView()
        NotificationCenter.default.addObserver(self, selector: #selector(updateNavigationItem), name:NSNotification.Name(rawValue: "Text_Edit_Done_Notification"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleResetImage() {
        currentImage = originalImage
        
        refreshImageView()
    }
    
    func setupButtons() {
        self.view.addSubview(resetImageButton)
        resetImageButton.anchor(top: nil, left: nil, bottom: self.menuView.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 5, paddingRight: 5, width: 50, height: 50)
    }
    
    
    func initMenuView() {
        if menuView == nil {
            
            let height = 80 + getBottomPadding()
            menuView = UIView(frame: CGRect(x: 0, y: view.height - height, width: self.view.width, height: height))
            self.view.addSubview(menuView)
            menuView.backgroundColor = XWImageEditorTheme.toolbarColor
        }
    }
    
    private func getBottomPadding() -> CGFloat {
        if #available(iOS 11.0, *) {
            if let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom,
                bottomPadding > 0 {
                return 20
            }
        }
        
        return 0
    }
    
    func initImageScrollView() {
        if scrollView == nil {
            scrollView = UIScrollView(frame: view.bounds)
            scrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.delegate = self
            scrollView.clipsToBounds = false
            if #available(iOS 11.0, *) {
                scrollView.contentInsetAdjustmentBehavior = .never
            } else {
                self.automaticallyAdjustsScrollViewInsets = false
            }
            
            if let top = navigationController?.navigationBar.bottom {
                scrollView.top = top
            }
            scrollView.height = view.height - scrollView.top - self.menuView.height
            self.view.insertSubview(scrollView, at: 0)
        }
    }
    
    func initToolSettings() {
        for subView in menuView.subviews {
            subView.removeFromSuperview()
        }
        
        var x: CGFloat = 0
        let W: CGFloat = 105
        let H: CGFloat = menuView.height
        let toolCount: CGFloat = 3
        
        var padding: CGFloat = 0
        
        let diff: CGFloat = menuView.frame.size.width - toolCount * W;
        if diff > 0 {
            padding = diff / (toolCount + 1)
        }
        
        for toolInfo: XWImageToolInfo in XWImageToolInfo.getToolInfos() {
            let frame = CGRect(x: x + padding, y: 0, width: W, height: H)
            
            let barItem = XWToolBarItem(frame: frame, target: self, action: #selector(tappedToolMenuItem(sender:)), toolInfo: toolInfo)
            self.menuView.addSubview(barItem)
            
            x += W + padding
        }
    }
    
    func initNavigationBar() {
        let next = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(imageEditFinishBtn))
        let reset = UIBarButtonItem.narrowButtonItem(image: UIImage.fontAwesomeIcon(name: .repeat, textColor: .black, size: CGSize.init(width: 30, height: 44)), target: self, action: #selector(handleResetImage))
        
        self.navigationItem.rightBarButtonItems = [next, UIBarButtonItem.fixNavigationSpacer(), reset, UIBarButtonItem.fixNavigationSpacer()]
        
    }

    
    func resetImageViewFrame() {
        var size: CGSize = imageView.frame.size
        if let imageSize = imageView.image?.size  {
            size = imageSize
        }
        if size.width > 0 && size.height > 0 {
            let ratio: CGFloat = min(scrollView.frame.size.width / size.width, scrollView.frame.size.height / size.height)
            let W = ratio * size.width * scrollView.zoomScale
            let H = ratio * size.height * scrollView.zoomScale
            imageView.frame = CGRect(x: max(0, (scrollView.width - W) / 2), y: max(0, (scrollView.height - H) / 2), width: W, height: H)
        }
    }
    
    func fixZoomScaleWithAnimated(animated: Bool) {
        let minZoomScale = scrollView.minimumZoomScale
        scrollView.maximumZoomScale = 0.92 * minZoomScale
        scrollView.minimumZoomScale = 0.92 * minZoomScale
        
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: animated)
    }
    
    func resetZoomScaleWithAnimated(animated:Bool) {
        var wR = scrollView.frame.size.width / imageView.frame.size.width
        var hR = scrollView.frame.size.height / imageView.frame.size.height
        
        let scale: CGFloat = 1
        if let img = imageView.image {
            wR = max(wR, img.size.width / (scale * scrollView.frame.size.width))
            hR = max(hR, img.size.height / (scale * scrollView.frame.size.height))
        }
        
        scrollView.contentSize = imageView.frame.size
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = max(max(wR, hR), 1)
        
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: animated)
    }
    
    func refreshImageView() {
        imageView.image = currentImage
        
        self.resetImageViewFrame()
        self.resetZoomScaleWithAnimated(animated: false)
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    @objc func imageEditFinishBtn() {
        CurrentUser.getUser { (curUser, error) in
            if let curUser = curUser {
                let previewPhotoController = PreviewPhotoController()
                previewPhotoController.user = self.userToSend
                previewPhotoController.currentUser = curUser
                previewPhotoController.editedImage = self.currentImage
                previewPhotoController.originalImage = self.originalImage
                self.navigationController?.pushViewController(previewPhotoController, animated: true)
            } else if let _ = error {
                AppHUD.error("Cannot retrieve current user. Please try again.", isDarkTheme: false)
                return
            }
        }
    }
    
    @objc func pushedCancelBtn() {
        imageView.image = currentImage
        self.resetImageViewFrame()
        
        self.configureCurrentTool(curtool: nil)
    }
    
    func configureCurrentTool(curtool: XWImageToolBase?) {
        if curtool?.toolInfo.toolName != self.currentTool?.toolInfo.toolName {
            self.currentTool?.cleanup()
            self.currentTool = curtool
            self.currentTool?.setup()
            
            self.swapToolBarWithEditting(editting: (curtool != nil))
        }
    }
        
    @objc func pushedDoneBtn() {
        self.view.isUserInteractionEnabled = false
        
        self.currentTool?.executeWithCompletion(completion: { (image, error) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            } else if let image = image {
                self.currentImage = image
                self.imageView.image = image
                self.resetImageViewFrame()
                self.configureCurrentTool(curtool: nil)
            }
            self.view.isUserInteractionEnabled = true
        })
    }
    
    
    @objc func tappedToolMenuItem(sender: UITapGestureRecognizer) {
        if let view = sender.view as? XWToolBarItem {
            view.alpha = 0.2
            UIView.animate(withDuration: 0.3, animations: {
                view.alpha = 1
            })
            
            self.setupToolWithToolInfo(toolInfo: view.toolInfo)
        }
    }
    
    func setupToolWithToolInfo(toolInfo: XWImageToolInfo?) {
        if self.currentTool != nil {
            return
        }
        
        guard let toolInfo = toolInfo else { return }
        if toolInfo.toolName == "cut" {
            let cutTool = XWCutTool(editor: self, toolInfo: toolInfo)
            self.configureCurrentTool(curtool: cutTool)
        } else if toolInfo.toolName == "mosaic" {
            let mosaicTool = XWMosaicTool(editor: self, toolInfo: toolInfo)
            self.configureCurrentTool(curtool: mosaicTool)
        } else if toolInfo.toolName == "emoji" {
            let emojiTool = XWEmojiTool(editor: self, toolInfo: toolInfo)
            self.configureCurrentTool(curtool: emojiTool)
        }
    }
    
    func swapToolBarWithEditting(editting: Bool) {
        UIView.animate(withDuration: 0.3) {
            if editting {
                self.menuView.transform = CGAffineTransform.init(translationX: 0, y: self.view.height - self.menuView.top)
            } else {
                self.menuView.transform = CGAffineTransform.identity
            }
        }
        if self.currentTool != nil {
            self.updateNavigationItem()
        } else {
            self.navigationItem.hidesBackButton = false
            self.initNavigationBar()
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    
    @objc func updateNavigationItem()  {
        self.navigationItem.rightBarButtonItems = []
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(pushedDoneBtn))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(pushedCancelBtn))
        self.navigationItem.hidesBackButton = true
    }
}

extension XWImageEditorController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let Ws = scrollView.frame.size.width - scrollView.contentInset.left - scrollView.contentInset.right
        let Hs = scrollView.frame.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom
        let W = imageView.frame.size.width
        let H = imageView.frame.size.height
        
        var rct = imageView.frame
        rct.origin.x = max((Ws - W) / 2, 0)
        rct.origin.y = max((Hs - H) / 2, 0)
        imageView.frame = rct
    }
}
