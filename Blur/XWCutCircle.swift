//
//  XWCutCircle.swift
//  TestTimer
//
//  Created by xiandong wang on 11/9/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit

class XWCutCircle: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let bounds = rect
        let x = bounds.size.width/2 - bounds.size.width/6
        let y = bounds.size.height/2 - bounds.size.height/6
        let width = bounds.size.width/3
        let height = bounds.size.height/3
        context.setFillColor(UIColor.red.cgColor)
        context.fillEllipse(in: CGRect(x: x, y: y, width: width, height: height))
    }
}
