//
//  XWScaleButton.swift
//  TestTimer
//
//  Created by xiandong wang on 11/9/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit

class XWScaleButton: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        let radius: CGFloat = 0.7;
        let x = 0.5 * (rect.size.width - radius * rect.size.width);
        let y = 0.5 * (rect.size.height - radius * rect.size.height);
        let width = radius * rect.size.width;
        let height = radius * rect.size.height;
        
        let rct = CGRect(x: x, y: y, width: width, height: height)
        
        context?.setFillColor(UIColor.white.cgColor)
        context?.fillEllipse(in: rct)
        
        context?.setStrokeColor(UIColor.black.cgColor)
        context?.setLineWidth(5)
        context?.strokeEllipse(in: rct)
    }
}
