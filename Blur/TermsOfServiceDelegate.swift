//
//  TermsOfServiceDelegate.swift
//  Blur
//
//  Created by xiandong wang on 4/10/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import UIKit

protocol termsOfServiceDelegate: class {
    func termsOfServiceDidAccept(_ termsController: EULAController)
    
    func termsOfServiceDidCancel(_ termsController: EULAController)
}
