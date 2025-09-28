//
//  ProfileCollectionViewCell.swift
//  instagram
//
//  Created by Müge Deniz on 3.12.2024.
//

import UIKit
import FirebaseAuth
import SDWebImage

class ProfileCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var postPhoto: UIImageView!
    var saveArray: [String]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        postPhoto.contentMode = .scaleAspectFill
        postPhoto.clipsToBounds = true
    }
    
    func configure(with posts: PostModel) {
        if let postPhotoURL = posts.postPhoto.first {
            postPhoto.sd_setImage(with: URL(string: postPhotoURL),
                                  placeholderImage: UIImage(named: "profilephoto"))
        } else {
            postPhoto.image = UIImage(named: "profilephoto")
        }
    }


}
