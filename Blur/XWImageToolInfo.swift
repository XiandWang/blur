//
//  XWImageToolInfo.swift
//  TestTimer
//
//  Created by xiandong wang on 11/13/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit
import Foundation

struct XWImageToolInfo {
    let toolName: String
    let title: String
    let iconImage: UIImage
    let orderNum: Int
    
    init(toolName: String, title: String, iconImage: UIImage, orderNum: Int) {
        self.toolName = toolName
        self.title = title
        self.iconImage = iconImage
        self.orderNum = orderNum
    }
    
    static func getToolInfos() -> Array<XWImageToolInfo> {
        let mosaicImage = UIImage.fontAwesomeIcon(name: .th, textColor: YELLOW_COLOR, size: CGSize(width: 44, height: 44))
        let cutImage = UIImage.fontAwesomeIcon(name: .scissors, textColor: YELLOW_COLOR, size: CGSize(width: 44, height: 44))
        let mosaicToolInfo = XWImageToolInfo(toolName: "mosaic", title: "Mosaic to hide", iconImage: mosaicImage, orderNum: 1)
        let cutToolInfo = XWImageToolInfo(toolName: "cut", title: "Cut to hide", iconImage: cutImage, orderNum: 2)
        return [mosaicToolInfo, cutToolInfo]
    }
}
