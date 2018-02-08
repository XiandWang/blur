//
//  AppTextField.swift
//  Blur
//
//  Created by xiandong wang on 12/5/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit

class AppTextField: UITextField {
    var border = CALayer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    func setupView() {
        self.borderStyle = UITextBorderStyle.none
        border = CALayer()
        let borderWidth: CGFloat = 2
        border.backgroundColor = BACKGROUND_GRAY.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - borderWidth, width: self.frame.size.width, height: borderWidth)
        self.layer.addSublayer(border)
    }
}
