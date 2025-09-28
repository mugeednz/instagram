//
//  MessageListTableViewCell.swift
//  instagram
//
//  Created by Müge Deniz on 11.12.2024.
//

import UIKit

class MessageListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
   
    func setUIList(userModel: UserModel) {
        profilePicImageView.setCornerRadius()
        self.nickNameLabel.text = userModel.userNickName
        self.profilePicImageView.sd_setImage(
            with: URL(string: userModel.profilePhoto ?? ""),
            placeholderImage: UIImage(named: "profilePhoto")
        )
    }
}
