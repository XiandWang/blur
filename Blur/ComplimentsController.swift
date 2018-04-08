//
//  ComplimentsController.swift
//  Blur
//
//  Created by xiandong wang on 3/15/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import UIKit
import Firebase
import AZDialogView

class ComplimentsController: UITableViewController {
    private let cellId = "complimentCellId"
    var compliments = [Compliment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Compliments"
        
        tableView.register(ComplimentCell.self, forCellReuseIdentifier: cellId)
        
        getCompliments()
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(navback))
        swipe.direction = .right
        view.addGestureRecognizer(swipe)
    }
    
    @objc func navback() {
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func getCompliments() {
        guard let curUid = Auth.auth().currentUser?.uid  else { return }
        let ref = FIRRef.getCompliments().document(curUid).collection("compliments")
        ref.order(by: "createdTime", descending: true).limit(to: 300).getDocuments { (snap, error) in
            if let error = error {
                AppHUD.error(error.localizedDescription, isDarkTheme: true)
                return
            }
            
            guard let complimentDocs = snap?.documents else { return }
            for doc in complimentDocs {
                let compliment = Compliment(dict: doc.data(), complimentId: doc.documentID)
                self.compliments.append(compliment)
            }
            if self.compliments.count > 0 {
                self.navigationItem.title = "Compliments (\(self.compliments.count))"
            }
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if compliments.count == 0 {
            TableViewHelper.emptyMessage(message: "No compliments yet~", viewController: self)
        } else {
            tableView.backgroundView = nil
        }
        return compliments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! ComplimentCell
        cell.compliment = self.compliments[safe: indexPath.row]
        cell.userImageView.tag = indexPath.row
        cell.userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowUserProfile)))
        return cell
    }
    
    @objc func handleShowUserProfile(sender: UITapGestureRecognizer) {
        guard let tag = sender.view?.tag else { return }
        guard let user = self.compliments[safe: tag]?.sender else { return }
        let userProfile = UserProfileController()
        userProfile.user = user
        self.navigationController?.pushViewController(userProfile, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let compliment = self.compliments[indexPath.row]
        let dialog = AZDialogViewController(title: compliment.sender?.fullName ?? "", message: compliment.complimentText, verticalSpacing: -1, buttonSpacing: 10, sideSpacing: 17, titleFontSize: 20, messageFontSize: 15, buttonsHeight: 44)
        dialog.dismissWithOutsideTouch = true
        dialog.blurBackground = true
        dialog.imageHandler = { (imageView) in
            imageView.image = UIImage.fontAwesomeIcon(name: .heart, textColor: PINK_COLOR, size: CGSize(width: 50, height: 50))
            imageView.backgroundColor = PINK_COLOR_LIGHT
            imageView.contentMode = .center
            return true //must return true, otherwise image won't show.
        }
        dialog.buttonStyle = { (button,height,position) in
            button.setTitleColor(PINK_COLOR, for: .normal)
            button.titleLabel?.font = TEXT_FONT
            button.layer.masksToBounds = true
            button.layer.borderColor = PINK_COLOR.cgColor
        }
        dialog.addAction(AZDialogAction(title: "close", handler: { (dialog) -> (Void) in
            dialog.dismiss()
        }))
        dialog.show(in: self)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let flagAction  = UITableViewRowAction(style: .destructive, title: "Flag") { (action, indexPath) in
            guard let compliment = self.compliments[safe: indexPath.row] else { return }
            let alert = UIAlertController(title: "Flag objectionalbe content?", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Flag", style: .default, handler: { (_) in
                Firestore.firestore().collection("complimentFlagReports").addDocument(data: ["complimentId": compliment.complimentId, "senderId": compliment.sender?.uid ?? ""], completion: { (error) in
                    if let error = error {
                        AppHUD.error(error.localizedDescription, isDarkTheme: true)
                        return
                    }
                    AppHUD.success("Your flag has been reported.", isDarkTheme: true)
                    self.compliments.remove(at: indexPath.row)
                    self.tableView.reloadData()
                })
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        return [flagAction]
    }
    
    override func didReceiveMemoryWarning() {
        self.compliments = Array(self.compliments.dropLast(200))
    }
}
