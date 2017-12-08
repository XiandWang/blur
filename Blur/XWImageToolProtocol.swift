//
//  XWImageToolProtocol.swift
//  TestTimer
//
//  Created by xiandong wang on 11/10/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import Foundation
import UIKit

protocol XWImageToolProtocol {
    
    static var defaultIconImage: UIImage? { get set }
    static var defaultTitle: String { get set }
    static var subtools: Array<String>? { get set }
    static var orderNum: Int { get set }
    
}
