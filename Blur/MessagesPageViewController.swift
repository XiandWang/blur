//
//  MessagesPageViewController.swift
//  Blur
//
//  Created by xiandong wang on 11/5/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit

class MessagesPageViewController: UIPageViewController {
    
    var messages: [Message]?
    
    var senderUser: User? {
        didSet {
            if let senderUser = senderUser {
                self.navigationController?.navigationItem.title = senderUser.username
            }
        }
    }
    
    var currentIndex: Int?
    
    init(messages: [Message], senderUser: User) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.messages = messages
        self.senderUser = senderUser
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = senderUser?.username ?? ""
        self.dataSource = self
        if let imageMessageController = configureImageMessageController(index: currentIndex ?? 0) {
            let controllers = [imageMessageController]
            
            self.setViewControllers(controllers, direction: .forward, animated: false, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        self.navigationController?.navigationBar.barTintColor = YELLOW_COLOR
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    func configureImageMessageController(index: Int) -> ReceiverImageMessageController? {
        let imageMessageController = ReceiverImageMessageController()
        if let message = messages?[index] {
            imageMessageController.message = message
            imageMessageController.senderUser = senderUser
            imageMessageController.photoIndex = index
            return imageMessageController
        }
        return nil
    }
}

extension MessagesPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? ReceiverImageMessageController,
            let index = viewController.photoIndex,
            index > 0 {
            return configureImageMessageController(index: index - 1)
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? ReceiverImageMessageController,
            let index = viewController.photoIndex,
            let count = messages?.count,
            (index + 1) < count {
            return configureImageMessageController(index: index + 1)
        }
        
        return nil
    }
}
