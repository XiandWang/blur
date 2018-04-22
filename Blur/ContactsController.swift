//
//  ContactsController.swift
//  Blur
//
//  Created by xiandong wang on 3/9/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import UIKit
import MessageUI
import Contacts
import Firebase
import AZDialogView

class ContactsController: UITableViewController, MFMessageComposeViewControllerDelegate {
    
    let cellId = "contactCellId"
    var contacts = [Contact]()
    var sectionContactDict = [String: [Contact]]()
    var contactSection = [String]()
    
    var contactsToSend = Set<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Invite"
        setupNavTitleAttr()
        view?.backgroundColor = .white
        tableView.sectionIndexColor = TEXT_GRAY
        
        tableView.register(ContactCell.self, forCellReuseIdentifier: cellId)
        setupNav()
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let _ = error {
                DispatchQueue.main.async {
                    self.showDialog()
                }
                return
            }
            
            if granted {
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
                let request = CNContactFetchRequest(keysToFetch: keys)
                do {
                    try store.enumerateContacts(with: request, usingBlock: { (cnContact, stopPointer) in
                        if let number = cnContact.phoneNumbers.first?.value.stringValue {
                            guard let letterChar = self.getFirstLetter(contact: cnContact) else { return }
                            let contact = Contact(familyName: cnContact.familyName, givenName: cnContact.givenName, number: number)
                            self.contacts.append(contact)
                            
                            let letter = "\(letterChar)".uppercased()
                            if let _ = self.sectionContactDict[letter] {
                                self.sectionContactDict[letter]?.append(contact)
                            } else {
                                self.sectionContactDict[letter] = [contact]
                            }
    
                            self.contactSection = self.sectionContactDict.keys.sorted()
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    })
                } catch let err {
                    DispatchQueue.main.async {
                        AppHUD.error(err.localizedDescription, isDarkTheme: true)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    TableViewHelper.emptyMessage(message: "Contacts permission denied. Please verbally invite your friends. Thank you.", viewController: self)
                    AppHUD.error("Contacts permission denied.😳", isDarkTheme: true)
                }
                return
            }
        }
    }
    
    func getFirstLetter(contact: CNContact) -> Character? {
        if let givenletter = contact.givenName.first {
            return givenletter
        } else if let familyLetter = contact.familyName.first {
            return familyLetter
        } else {
            return nil
        }
    }
    
    func setupNav() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(sendInvites))
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(navback))
        swipe.direction = .right
        view.addGestureRecognizer(swipe)
    }
    
    @objc func navback() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CurrentUser.numInvites == 0 && !CurrentUser.hasShownInviteDialog {
            CurrentUser.hasShownInviteDialog = true
            let dialog = AZDialogViewController(title: "Invite to unlock", message: "3 invites unlock complimenting. 5 invites unlock asking for chats!", verticalSpacing: -1, buttonSpacing: 10, sideSpacing: 20, titleFontSize: 20, messageFontSize: 15, buttonsHeight: 44)
            dialog.dismissWithOutsideTouch = true
            dialog.blurBackground = false
            dialog.imageHandler = { (imageView) in
                imageView.image = UIImage.fontAwesomeIcon(name: .unlockAlt, textColor: BLUE_COLOR, size: CGSize(width: 50, height: 50))
                imageView.backgroundColor = BLUE_COLOR_LIGHT
                imageView.contentMode = .center
                return true //must return true, otherwise image won't show.
            }
            dialog.cancelEnabled = true
            
            dialog.buttonStyle = { (button,height,position) in
                button.setTitleColor(BLUE_COLOR, for: .normal)
                button.titleLabel?.font = TEXT_FONT
                button.layer.masksToBounds = true
                button.layer.borderColor = BLUE_COLOR.cgColor
            }
            dialog.addAction(AZDialogAction(title: "Sure", handler: { (dialog) -> (Void) in
                if CNContactStore.authorizationStatus(for: .contacts) == .denied {
                    dialog.removeAllActions()
                    dialog.title = "Grant contacts permission?"
                    dialog.message = nil
                    dialog.addAction(AZDialogAction(title: "Grant permission", handler: { (dialog) -> (Void) in
                        self.openPermissions()
                        dialog.dismiss()
                    }))
                    dialog.addAction(AZDialogAction(title: "Later", handler: { (dialog) -> (Void) in
                        dialog.dismiss()
                    }))
                } else {
                    dialog.dismiss()
                }
            }))
            dialog.show(in: self)
            return
        }
    }
    
    func showDialog() {
        let dialog = AZDialogViewController(title: "Invite to unlock", message: "3 invites unlock complimenting. 5 invites unlock asking for chats!", verticalSpacing: -1, buttonSpacing: 10, sideSpacing: 20, titleFontSize: 20, messageFontSize: 15, buttonsHeight: 44)
        dialog.dismissWithOutsideTouch = true
        dialog.blurBackground = false
        dialog.imageHandler = { (imageView) in
            imageView.image = UIImage.fontAwesomeIcon(name: .unlockAlt, textColor: BLUE_COLOR, size: CGSize(width: 50, height: 50))
            imageView.backgroundColor = BLUE_COLOR_LIGHT
            imageView.contentMode = .center
            return true //must return true, otherwise image won't show.
        }
        dialog.cancelEnabled = true
        
        dialog.buttonStyle = { (button,height,position) in
            button.setTitleColor(BLUE_COLOR, for: .normal)
            button.titleLabel?.font = TEXT_FONT
            button.layer.masksToBounds = true
            button.layer.borderColor = BLUE_COLOR.cgColor
        }
        dialog.addAction(AZDialogAction(title: "Sure", handler: { (dialog) -> (Void) in
            if CNContactStore.authorizationStatus(for: .contacts) == .denied {
                dialog.removeAllActions()
                dialog.title = "Grant contacts permission?"
                dialog.message = nil
                dialog.addAction(AZDialogAction(title: "Grant permission", handler: { (dialog) -> (Void) in
                    self.openPermissions()
                    dialog.dismiss()
                }))
                dialog.addAction(AZDialogAction(title: "Later", handler: { (dialog) -> (Void) in
                    dialog.dismiss()
                }))
            } else {
                dialog.dismiss()
            }
        }))
        dialog.show(in: self)
    }
    
    fileprivate func openPermissions() {
        guard let url = URL(string: UIApplicationOpenSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, completionHandler: nil)
        }
    }
    
    @objc func sendInvites() {
        if contactsToSend.isEmpty {
            AppHUD.error("Please select at least one contact.", isDarkTheme: true)
            return
        }
    
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = self
        controller.body = "Hi I am using HidingChat to tease with my friends. You should join me too. Get it on App Store! Link: https://itunes.apple.com/us/app/hidingchat/id1366697857?ls=1&mt=8"
        controller.recipients  = Array(contactsToSend)
        self.present(controller, animated: true, completion: nil)
    }
    
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return contactSection
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitle = contactSection[section]
        guard let contacts = sectionContactDict[sectionTitle] else { return 0 }
        return contacts.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.contactSection.count == 0 {
            TableViewHelper.emptyMessage(message: "No contacts found", viewController: self)
        } else {
            tableView.backgroundView = nil
        }
        return self.contactSection.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return contactSection[section]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ContactCell else { return }
        if cell.isChosen {
            cell.isChosen = false
            contactsToSend.remove(cell.contact!.number)
        } else {
            cell.isChosen = true
            contactsToSend.insert(cell.contact!.number)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        if result == .failed {
            AppHUD.error("Failed to send invitations", isDarkTheme: true)
        } else if result == .sent {
            CurrentUser.numInvites += self.contactsToSend.count
            AppHUD.success("Thank you", isDarkTheme: true)
            guard let uid = Auth.auth().currentUser?.uid else { return }
            Database.database().reference().child("invites").child(uid).setValue(["num": CurrentUser.numInvites])
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! ContactCell
        
        if let contact = getContact(from: indexPath) {
            cell.contact = contact
            return cell
        }


        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.tintColor = BACKGROUND_GRAY
            headerView.textLabel?.font = SMALL_TEXT_FONT
            headerView.textLabel?.textColor = TEXT_GRAY
        }
    }

    fileprivate func getContact(from indexPath: IndexPath) -> Contact? {
        let title = contactSection[indexPath.section]
        guard let users = sectionContactDict[title] else { return nil}
        let user = users[indexPath.row]
        
        return user
    }
}

struct Contact {
    let familyName: String
    let givenName: String
    let number: String
    
    init(familyName: String, givenName: String, number: String) {
        self.familyName = familyName
        self.givenName = givenName
        self.number = number
    }
}
