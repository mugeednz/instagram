//
//  SearchTableViewCell.swift
//  instagram
//
//  Created by Müge Deniz on 2.12.2024.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    
    func setUI(userModel: UserModel) {
        nickNameLabel.text = userModel.userNickName
        profilePhoto.sd_setImage(with: URL(string: userModel.profilePhoto ?? ""),
                                         placeholderImage: UIImage(named: "profilephoto"))
        profilePhoto.setCornerRadius()
    }

    
}
