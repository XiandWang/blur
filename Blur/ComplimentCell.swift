//
//  ComplimentCell.swift
//  Blur
//
//  Created by xiandong wang on 3/15/18.
//  Copyright © 2018 xiandong wang. All rights reserved.
//

import Foundation

class ComplimentCell: UITableViewCell {
    
    var compliment: Compliment? {
        didSet {
            if let compliment = compliment, let user = compliment.sender {
                
                self.complimentLabel.attributedText = self.buildText(compliment: compliment, user: user)
                
                if let url =  user.profileImgUrl {
                    self.userImageView.kf.setImage(with: URL(string: url))
                } else {
                    self.userImageView.kf.setImage(with: nil)
                }
            } else {
                self.userImageView.kf.setImage(with: nil)
            }
        }
    }
    
    let complimentLabel : UILabel = {
        let lb = UILabel()
        lb.font = BOLD_FONT
        lb.numberOfLines = 0
        lb.text = ""
        return lb
    }()
    
    let userImageView : UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 25
        iv.layer.masksToBounds = true
        iv.backgroundColor = BACKGROUND_GRAY
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        return iv
    }()

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(complimentLabel)
        contentView.addSubview(userImageView)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        userImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        complimentLabel.anchor(top: contentView.topAnchor, left: userImageView.rightAnchor, bottom: nil, right: contentView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        complimentLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func buildText(compliment: Compliment, user: User) -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString(string: user.fullName + ": ", attributes: [NSAttributedStringKey.font: BOLD_FONT, NSAttributedStringKey.foregroundColor: UIColor.black])
        
        attributedText.append(NSAttributedString(string: compliment.complimentText, attributes: [NSAttributedStringKey.font: TEXT_FONT, NSAttributedStringKey.foregroundColor: UIColor.black]))
        
        attributedText.append(NSAttributedString(string: " • " + compliment.createdTime.timeAgoDisplay(), attributes: [NSAttributedStringKey.font: UIFont(name: APP_FONT, size: 13) ?? TEXT_FONT, NSAttributedStringKey.foregroundColor: UIColor.lightGray]))
        return attributedText
    }
}
