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
    //let iconImage: UIImage
    let orderNum: Int
    
    init(toolName: String, title: String, iconImage: UIImage?, orderNum: Int) {
        self.toolName = toolName
        self.title = title
        //self.iconImage = iconImage
        self.orderNum = orderNum
    }
    
    static func getToolInfos() -> Array<XWImageToolInfo> {
        let mosaicToolInfo = XWImageToolInfo(toolName: "mosaic", title: "Mosaic to hide", iconImage: nil, orderNum: 1)
        let cutToolInfo = XWImageToolInfo(toolName: "cut", title: "Cut to hide", iconImage: nil, orderNum: 2)
        return [mosaicToolInfo, cutToolInfo]
    }
}
