//
//  EULAController.swift
//  Blur
//
//  Created by xiandong wang on 4/8/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import UIKit
import Firebase

class EULAController: UIViewController {

    weak var delegate: termsOfServiceDelegate?
    
    let generalLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = TEXT_GRAY
        lb.font = TEXT_FONT
        lb.sizeToFit()
        lb.numberOfLines = 0
        lb.text = "HidingChat App End User License Agreement. \n\nThis End User License Agreement (“Agreement”) is between you and HidingChat and governs use of this app made available through the Apple App Store. By installing the HidingChat App, you agree to be bound by this Agreement and understand that there is no tolerance for objectionable content. If you do not agree with the terms and conditions of this Agreement, you are not entitled to use the HidingChat App.\n\nIn order to ensure HidingChat provides the best experience possible for everyone, we strongly enforce a no tolerance policy for objectionable content. If you see inappropriate content, please use the “Flag as objectionable” feature."
        return lb
    }()
    
    let partiesLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = TEXT_GRAY
        lb.font = TEXT_FONT
        lb.sizeToFit()
        lb.numberOfLines = 0
        lb.text = "1. Parties\n\nThis Agreement is between you and HidingChat only, and not Apple, Inc. (“Apple”). Notwithstanding the foregoing, you acknowledge that Apple and its subsidiaries are third party beneficiaries of this Agreement and Apple has the right to enforce this Agreement against you. HidingChat, not Apple, is solely responsible for the HidingChat App and its content."
        return lb
    }()
    
    let privacyLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = TEXT_GRAY
        lb.font = TEXT_FONT
        lb.sizeToFit()
        lb.numberOfLines = 0
        lb.text = "2. Privacy\n\nHidingChat may collect and use information about your usage of the HidingChat App, including certain types of information from and about your device. HidingChat may use this information, as long as it is in a form that does not personally identify you, to measure the use and performance of the HidingChat App."
        return lb
    }()
    
    let licenseeLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = TEXT_GRAY
        lb.font = TEXT_FONT
        lb.sizeToFit()
        lb.numberOfLines = 0
        lb.text = "3. Limited License\n\nHidingChat grants you a limited, non-exclusive, non-transferable, revocable license to use the HidingChat App for your personal, non-commercial purposes. You may only use the HidingChat App on Apple devices that you own or control and as permitted by the App Store Terms of Service."
        return lb
    }()
    
    
    let ageLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = TEXT_GRAY
        lb.font = TEXT_FONT
        lb.sizeToFit()
        lb.numberOfLines = 0
        lb.text = "4. Age Restrictions\n\nBy using the HidingChat App, you represent and warrant that (a) you are 13 years of age or older and you agree to be bound by this Agreement; (b) if you are under 13 years of age, you have obtained verifiable consent from a parent or legal guardian; and (c) your use of the HidingChat App does not violate any applicable law or regulation. Your access to the HidingChat App may be terminated without warning if HidingChat believes, in its sole discretion, that you are under the age of 13 years and have not obtained verifiable consent from a parent or legal guardian. If you are a parent or legal guardian and you provide your consent to your child’s use of the HidingChat App, you agree to be bound by this Agreement in respect to your child’s use of the HidingChat App."
        return lb
    }()
    
    let objectionableLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = TEXT_GRAY
        lb.font = TEXT_FONT
        lb.sizeToFit()
        lb.numberOfLines = 0
        lb.text = "5. Objectionable Content Policy\n\nContent may not be submitted to HidingChat, who will moderate all content and ultimately decide whether or not to post a submission to the extent such content includes, is in conjunction with, or alongside any, Objectionable Content. Objectionable Content includes, but is not limited to: (a) sexually explicit materials; (b) obscene, defamatory, libelous, slanderous, violent and/or unlawful content or profanity; (c) content that infringes upon the rights of any third party, including copyright, trademark, privacy, publicity or other personal or proprietary right, or that is deceptive or fraudulent; (d) content that promotes the use or sale of illegal or regulated substances, tobacco products, ammunition and/or firearms; and (e) gambling, including without limitation, any online casino, sports books, bingo or poker. "
        return lb
    }()
    
    let restrictionsOnUseLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = TEXT_GRAY
        lb.font = TEXT_FONT
        lb.sizeToFit()
        lb.numberOfLines = 0
        lb.text = "6. Restrictions on Use\n\nYou shall not (a) decompile, reverse engineer, disassemble, attempt to derive the source code of, or decrypt the Application; (b) make any modification, adaptation, improvement, enhancement, translation or derivative work from the app; (c) violate any applicable laws, rules or regulations in connection with Your access or use of the app; (d) use the app for any revenue generating endeavor, commercial enterprise, or other purpose for which it is not designed or intended; (e) use the app for creating a product, service or software that is, directly or indirectly, competitive with or in any way a substitute for any services, product or software offered by the app."
        return lb
    }()
    
    let liabilityLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = TEXT_GRAY
        lb.font = TEXT_FONT
        lb.sizeToFit()
        lb.numberOfLines = 0
        lb.text = "7. Limitation of Liability\n\nUNDER NO CIRCUMSTANCES SHALL THE HIDINGCHAT APP BE LIABLE FOR ANY INDIRECT, INCIDENTAL, CONSEQUENTIAL, SPECIAL OR EXEMPLARY DAMAGES ARISING OUT OF OR IN CONNECTION WITH YOUR ACCESS OR USE OF OR INABILITY TO ACCESS OR USE THE APPLICATION AND ANY THIRD PARTY CONTENT AND SERVICES, WHETHER OR NOT THE DAMAGES WERE FORESEEABLE AND WHETHER OR NOT COMPANY WAS ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. WITHOUT LIMITING THE GENERALITY OF THE FOREGOING, HIDINGCHAT'S AGGREGATE LIABILITY TO YOU (WHETHER UNDER CONTRACT, TORT, STATUTE OR OTHERWISE) SHALL NOT EXCEED THE AMOUNT OF FIFTY DOLLARS ($50.00). THE FOREGOING LIMITATIONS WILL APPLY EVEN IF THE ABOVE STATED REMEDY FAILS OF ITS ESSENTIAL PURPOSE."
        
        return lb
    }()
    
    let warrantiesLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = TEXT_GRAY
        lb.font = TEXT_FONT
        lb.sizeToFit()
        lb.numberOfLines = 0
        lb.text = "8. Disclaim of Warranties\n\nTHE SERVICES ARE PROVIDED “AS IS” AND “AS AVAILABLE” AND TO THE EXTENT PERMITTED BY LAW WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND NON-INFRINGEMENT. IN ADDITION, WHILE HIDINGCHAT ATTEMPTS TO PROVIDE A GOOD USER EXPERIENCE, WE DO NOT REPRESENT OR WARRANT THAT: (A) THE SERVICES WILL ALWAYS BE SECURE, ERROR-FREE, OR TIMELY; (B) THE SERVICES WILL ALWAYS FUNCTION WITHOUT DELAYS, DISRUPTIONS, OR IMPERFECTIONS; OR (C) THAT ANY CONTENT, USER CONTENT, OR INFORMATION YOU OBTAIN ON OR THROUGH THE SERVICES WILL BE TIMELY OR ACCURATE.\n\tHIDINGCHAT APP TAKES NO RESPONSIBILITY AND ASSUMES NO LIABILITY FOR ANY CONTENT THAT YOU, ANOTHER USER, OR A THIRD PARTY CREATES, UPLOADS, SENDS, RECEIVES, OR STORES ON OR THROUGH OUR SERVICES. YOU UNDERSTAND AND AGREE THAT YOU MAY BE EXPOSED TO CONTENT THAT MIGHT BE OFFENSIVE, ILLEGAL, MISLEADING, OR OTHERWISE INAPPROPRIATE, NONE OF WHICH HIDINGCHAT APP WILL BE RESPONSIBLE FOR."
        return lb
    }()
    
    let terminationLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = TEXT_GRAY
        lb.font = TEXT_FONT
        lb.sizeToFit()
        lb.numberOfLines = 0
        lb.text = "9. Modifying the Services and Termination\n\nAs HidingChat is relatively a new app, the service might be modified at any time. HidingChat may also terminate these terms with you at any time, for any reason, and without advanced notice.  For example, we may deactivate your account due to sending offsensive information, and we may reclaim your username at any time for any reason."
        return lb
    }()
    
    let supportLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = TEXT_GRAY
        lb.font = TEXT_FONT
        lb.sizeToFit()
        lb.numberOfLines = 0
        lb.text = "10. Maintenance and Support\n\nHidingChat does provide minimal maintenance or support for it but not to the extent that any maintenance or support is required by applicable law, HidingChat, not Apple, shall be obligated to furnish any such maintenance or support."
        return lb
    }()
    
    let productClaimsLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = TEXT_GRAY
        lb.font = TEXT_FONT
        lb.sizeToFit()
        lb.numberOfLines = 0
        lb.text = "11. Product Claims\n\nHidingChat, not Apple, is responsible for addressing any claims by you relating to the HidingChat App or use of it, including, but not limited to: (a) any product liability claim; (b) any claim that the HidingChat App fails to conform to any applicable legal or regulatory requirement; and (c) any claim arising under consumer protection or similar legislation. Nothing in this Agreement shall be deemed an admission that you may have such claims."
        return lb
    }()
    
    let thirdPartyLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = TEXT_GRAY
        lb.font = TEXT_FONT
        lb.sizeToFit()
        lb.numberOfLines = 0
        lb.text = "12. Third Party Intellectual Property Claims\n\nHidingChat shall not be obligated to indemnify or defend you with respect to any third party claim arising out or relating to the HidingChat App. To the extent HidingChat is required to provide indemnification by applicable law, HidingChat, not Apple, shall be solely responsible for the investigation, defense, settlement and discharge of any claim that the HidingChat App or your use of it infringes any third party intellectual property right."
        return lb
    }()
    
    var uid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Terms of Service"
        
        view.backgroundColor = .white
        setupView()
        
    }
    
    @objc func handleAccept() {
        guard let uid = self.uid else { return }
        Database.database().reference().child("users/\(uid)/hasAcceptedTerms").setValue(true)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleReject() {
        do {
            CurrentUser.user = nil
            self.stopListeners()
            try Auth.auth().signOut()
            let navController = UINavigationController(rootViewController: ChooseLoginSignupController())
            self.present(navController, animated: true) {
                AppHUD.error("Logging you out becasue you didn't accept the Terms of Service", isDarkTheme: true)
            }
        } catch let signOutError {
            AppHUD.error("Signout error: " + signOutError.localizedDescription, isDarkTheme: true)
        }
    }
    
    func setupView() {
        let scrollView = UIScrollView(frame: view.frame)
        
        scrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(scrollView)
        
        var y: CGFloat = 0
        
        for v in [generalLabel, partiesLabel, privacyLabel, licenseeLabel, ageLabel, objectionableLabel, restrictionsOnUseLabel, liabilityLabel, warrantiesLabel, terminationLabel, supportLabel, productClaimsLabel, thirdPartyLabel] {
            let rect = NSString(string: v.text!).boundingRect(with: CGSize(width:view.width - 24, height:999), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedStringKey.font: TEXT_FONT], context: nil).size
            scrollView.addSubview(v)
            v.frame = CGRect(x: 12, y: y, width: view.frame.width - 24
                , height: rect.height + 40)
            y += rect.height + 40
        }
        
        scrollView.contentSize = CGSize(width: view.frame.width, height: y)
    }
}
