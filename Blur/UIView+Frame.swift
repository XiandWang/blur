//
//  UIView+Frame.swift
//  TestTimer
//
//  Created by xiandong wang on 11/8/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit

extension UIView {

    var top: CGFloat {
        get {
            return self.frame.origin.y
        }
        
        set(top) {
            self.frame.origin.y = top;
        }
    }
    
    var right: CGFloat {
        get {
            return self.frame.origin.x + self.frame.size.width
        }
        
        set(newRight) {
            self.frame.origin.x = newRight - self.frame.size.width;
        }
    }
    
    var bottom: CGFloat {
        get {
            return self.frame.origin.y + self.frame.size.height
        }
        
        set(newBottom) {
            self.frame.origin.y = newBottom - self.frame.size.height;
        }
    }
    
    var left: CGFloat {
        get {
            return self.frame.origin.x
        }
        
        set(newLeft) {
            self.frame.origin.x = newLeft;
        }
    }
    
    var width: CGFloat {
        get {
            return self.frame.size.width
        }
        
        set(newWidth) {
            self.frame.size.width = newWidth
        }
    }
    
    var height: CGFloat {
        get {
            return self.frame.size.height
        }
        
        set(newHeight) {
            self.frame.size.height = newHeight
        }
    }
}
