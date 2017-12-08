//
//  XWImageToolBase.swift
//  TestTimer
//
//  Created by xiandong wang on 11/14/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit

class XWImageToolBase {
    static let ANIMATION_DURATION = 0.3
    
    let editor: XWImageEditorController
    let toolInfo: XWImageToolInfo
    
    init(editor: XWImageEditorController, toolInfo: XWImageToolInfo) {
        self.editor = editor
        self.toolInfo = toolInfo
    }
    
    func setup() {
        
    }
    
    func cleanup() {
        
    }
    
    func executeWithCompletion(completion: @escaping (_ image: UIImage?, _ error: String?) -> ()) {
        
    }
}
