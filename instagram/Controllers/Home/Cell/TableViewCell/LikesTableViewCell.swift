//
//  ReviewLikeTableViewCell.swift
//  instagram
//
//  Created by Müge Deniz on 19.11.2024.
//

import UIKit
import SDWebImage

class LikesTableViewCell: UITableViewCell {
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userNickNameLabel: UILabel!
    
    func setUI(userModel: UserModel) {
        userNickNameLabel.text = userModel.userNickName
        userProfileImageView.sd_setImage(with: URL(string: userModel.profilePhoto ?? ""),
                                         placeholderImage: UIImage(named: "profilephoto"))
        userProfileImageView.setCornerRadius()
    }
    
}
