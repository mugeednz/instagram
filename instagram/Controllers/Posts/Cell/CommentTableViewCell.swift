//
//  CommentTableViewCell.swift
//  instagram
//
//  Created by Müge Deniz on 30.11.2024.
//

import UIKit
import SDWebImage

class CommentTableViewCell: UITableViewCell {
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    func setUI(userModel: UserModel, commentModel: CommentModel) {
        nickNameLabel.text = userModel.userNickName
        commentLabel.text = commentModel.commentText
        let userPP = URL(string: userModel.profilePhoto ?? "")
        profilePhotoImageView.sd_setImage(with: userPP)
    }

}
