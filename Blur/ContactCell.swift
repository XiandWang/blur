//
//  ContactCell.swift
//  Blur
//
//  Created by xiandong wang on 3/9/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import UIKit


class ContactCell : UITableViewCell {
    let circle = UIImage.fontAwesomeIcon(name: .circleO, textColor: PURPLE_COLOR.withAlphaComponent(0.8), size: CGSize(width: 30, height: 30))
    let circleO = UIImage.fontAwesomeIcon(name: .dotCircleO, textColor:  PURPLE_COLOR.withAlphaComponent(0.8), size: CGSize(width: 30, height: 30))

    var isChosen: Bool = false {
        didSet {
            if isChosen {
                self.selectedImageView.image = circleO
            } else {
                self.selectedImageView.image = circle
            }
        }
    }
    
    var contact: Contact? {
        didSet {
            if let contact = contact {
                nameLabel.text = (contact.givenName + " " + contact.familyName).trimmingCharacters(in: .whitespacesAndNewlines)
                numberLabel.text = contact.number
            }
        }
    }
    
    lazy var selectedImageView : UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .center
        iv.image = self.circle
        

        return iv
    }()
    
    let nameLabel : UILabel = {
        let lb = UILabel()
        lb.font = BOLD_FONT
        lb.numberOfLines = 1
        lb.text = ""
        lb.textAlignment = .left
        return lb
    }()
    
    let numberLabel : UILabel = {
        let lb = UILabel()
        lb.font = TEXT_FONT
        lb.textColor = .lightGray
        lb.numberOfLines = 1
        lb.textAlignment = .left
        lb.text = ""
        return lb
    }()
    
  
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.addSubview(selectedImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(numberLabel)
        setupConstraints()
    }
    
    func setupConstraints() {
        nameLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        numberLabel.anchor(top: nameLabel.bottomAnchor, left: contentView.leftAnchor , bottom: nil, right: nil, paddingTop: 4, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        selectedImageView.anchor(top: nil, left: nil, bottom: nil, right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 40, height: 40)
        selectedImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
