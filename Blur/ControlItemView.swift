//
//  MessageControlView.swift
//  Blur
//
//  Created by xiandong wang on 1/26/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import UIKit

class ControlItemView: UIView {
    
    var itemInfo: ControlItemInfo? {
        didSet {
            if let itemInfo = itemInfo {
                itemButton.backgroundColor = itemInfo.backgroundColor
                itemButton.setImage(itemInfo.image, for: .normal)
                
                itemLabel.text = itemInfo.itemText
                itemLabel.textColor = itemInfo.textColor
            }
        }
    }
    
    var itemButton: UIButton = {
        let bt = UIButton()
        bt.layer.cornerRadius = 25
        bt.layer.masksToBounds = true
        
        return bt
    }()
    
    lazy var itemLabel: UILabel = {
        let lb = UILabel()
        lb.font = TEXT_FONT
        lb.textAlignment = .center
        return lb
    }()
    
    
    init(target: Any, action: Selector) {
        super.init(frame: .zero)
        addSubview(itemButton)
        addSubview(itemLabel)
        itemButton.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        itemButton.anchor(top: topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 1, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        itemButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        itemLabel.anchor(top: itemButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 120, height: 0)
        itemLabel.centerXAnchor.constraint(equalTo: itemButton.centerXAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
