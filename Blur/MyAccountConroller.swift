//
//  MyAccountConroller.swift
//  Blur
//
//  Created by xiandong wang on 12/30/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import UIKit
import Firebase

class MyAccountController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private let headerId = "myAccountHeaderId"
    private let cellId = "myAccountCellId"
    var user: User?
    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.alwaysBounceVertical = true
        collectionView?.contentInset = UIEdgeInsetsMake(12, 0, 0, 0)
        collectionView?.backgroundColor = .white
        collectionView?.register(MyAccountHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.register(MyAccountImageCell.self, forCellWithReuseIdentifier: cellId)
        getUser()
        //listenForMessages()
        //getMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getMessages()
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! MyAccountHeader
        header.user = user
        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 104)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MyAccountImageCell
        cell.message = messages[indexPath.item]
        cell.backgroundColor = .lightGray
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    fileprivate func getUser() {
        guard let uid = Auth.auth().currentUser?.uid else {
            AppHUD.error("Cannot retrieve the current user")
            return
        }
        Database.database().reference().child(USERS_NODE).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userDict = snapshot.value as? [String: Any] else { return }
            let uid = snapshot.key
            self.user = User(dictionary: userDict, uid: uid)
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }) { (error) in
            AppHUD.error(error.localizedDescription)
            return
        }
    }
    
//    fileprivate func listenForMessages() {
//        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
//        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
//        Firestore.firestore().collection("imageMessages").whereField("fromId", isEqualTo: currentUserId).addSnapshotListener { (messagesSnap, error) in
//            if let error = error {
//                AppHUD.error(error.localizedDescription)
//                return
//            }
//            print(messagesSnap?.documentChanges.count ?? 0)
//            messagesSnap?.documentChanges.forEach({ (docChange: DocumentChange) in
//                if docChange.type == .added {
//                    let doc = docChange.document
//                    let message = Message(dict: doc.data(), messageId: doc.documentID)
//                    self.messages.insert(message, at: 0)
//                    DispatchQueue.main.async {
//                        self.collectionView?.reloadData()
//                    }
//                }
//            })
      //  }
    //}
    
    func getMessages() {
        self.messages = []
        AppHUD.progress(nil)
    
        let yesterday = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("imageMessages").whereField("fromId", isEqualTo: currentUserId).whereField("createdTime", isGreaterThan: yesterday).getDocuments { (messagesSnap, error) in
            AppHUD.progressHidden()
            if let error = error {
                print(error.localizedDescription)
                AppHUD.error(error.localizedDescription)
                return
            }
            print(messagesSnap?.count)
            print(messagesSnap?.documents.count)
            messagesSnap?.documents.forEach({ (doc) in
                let message = Message(dict: doc.data(), messageId: doc.documentID)
                self.messages.insert(message, at: 0)
                self.collectionView?.reloadData()
            })
        }
    }
}
