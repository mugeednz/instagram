//
//  CollectionViewCell.swift
//  instagram
//
//  Created by Müge Deniz on 23.11.2024.
//

import UIKit
import SDWebImage

class StoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var gradientView: GradientRoundedView!
    private var borderLayer: CALayer?

    func configure(with user: UserModel) {
        profileImageView.sd_setImage(with: URL(string: user.profilePhoto ?? "" ),
                                     placeholderImage: UIImage(named: "profilephoto"))
        profileImageView.setCornerRadius()
        nickNameLabel.text = user.userNickName
        nickNameLabel.adjustsFontSizeToFitWidth = true
        gradientView.rotate360(repeatCount: 1)
    }
 
}
