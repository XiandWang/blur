//
//  XWToolBarItem.swift
//  TestTimer
//
//  Created by xiandong wang on 11/13/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit

class XWToolBarItem: UIView {
    
    var selected: Bool = false
    
    lazy var iconView: UIImageView = {
        let iv = UIImageView(frame: CGRect(x: 35, y: 10, width: 35, height: 35))
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 5
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: self.iconView.bottom, width: self.frame.size.width, height: 15))
        label.backgroundColor = .clear
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        label.textColor = YELLOW_COLOR
        return label
    }()
    
    var toolInfo: XWImageToolInfo?
    
    init(frame: CGRect, target: Any, action: Selector, toolInfo: XWImageToolInfo) {
        super.init(frame: frame)
        
        addSubview(iconView)
        addSubview(titleLabel)

        let gesture = UITapGestureRecognizer(target: target, action: action)
        addGestureRecognizer(gesture)
        self.toolInfo = toolInfo
        titleLabel.text = toolInfo.title
        iconView.image = toolInfo.iconImage
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSelected(selected: Bool) {
        if self.selected != selected {
            self.selected = selected
            if selected {
                self.backgroundColor = .gray
            } else {
                self.backgroundColor = .clear
            }
        }
    }
    
    func setUserInteraction(isEnabled: Bool) {
        super.isUserInteractionEnabled = isEnabled
        
        self.alpha = isEnabled ? 1 : 0.3
    }
}
