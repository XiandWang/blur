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
    
    var fromUser: User? {
        didSet {
            if let fromUser = fromUser {
                self.navigationController?.navigationItem.title = fromUser.username
            }
        }
    }
    
    var currentIndex: Int?
    
    init(messages: [Message], fromUser: User) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.messages = messages
        self.fromUser = fromUser
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = fromUser!.username
        self.dataSource = self
        if let imageMessageController = configureImageMessageController(index: currentIndex ?? 0) {
            let controllers = [imageMessageController]
            
            self.setViewControllers(controllers, direction: .forward, animated: false, completion: nil)
        }
    }
    
    func configureImageMessageController(index: Int) -> ImageMessageController? {
        let imageMessageController = ImageMessageController()
        if let message = messages?[index] {
            imageMessageController.message = message
            imageMessageController.fromUser = fromUser
            imageMessageController.photoIndex = index
            return imageMessageController
        }
        return nil
    }
}

extension MessagesPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? ImageMessageController,
            let index = viewController.photoIndex,
            index > 0 {
            return configureImageMessageController(index: index - 1)
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? ImageMessageController,
            let index = viewController.photoIndex,
            let count = messages?.count,
            (index + 1) < count {
            return configureImageMessageController(index: index + 1)
        }
        
        return nil
    }
}
