//
//  ContrilItemInfo.swift
//  Blur
//
//  Created by xiandong wang on 1/26/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import UIKit
import Foundation

struct ControlItemInfo {
    let image: UIImage
    let backgroundColor: UIColor
    let textColor: UIColor
    let itemText: String
    
    init(image: UIImage, backgroundColor: UIColor, textColor: UIColor, itemText: String) {
        self.image = image
        self.backgroundColor = backgroundColor
        self.itemText = itemText
        self.textColor = textColor
    }
}
