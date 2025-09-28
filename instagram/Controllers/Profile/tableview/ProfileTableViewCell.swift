//
//  ProfileTableViewCell.swift
//  instagram
//
//  Created by Müge Deniz on 5.12.2024.
//

import UIKit
import FirebaseAuth

protocol ProfileTableViewCellDelegate: AnyObject {
    func didTapFollowers(followerType: FollowerType)
}

class ProfileTableViewCell: UITableViewCell, ProfileEditViewControllerDelegate {
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var profileEditButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var bioInfoLabel: UILabel!
    @IBOutlet weak var postCountLabel: UILabel!
    
    var users: [UserModel] = []
    var user: UserModel?
    var userId: String?
    //bu sadece takip akisi icin kullanilacak !!!!
    var currentUser: UserModel?
    var showProfile: ((_ selectedUser: UserModel) -> Void)?
    weak var delegate: ProfileTableViewCellDelegate?  // Delegate ataması
    
    func configure(with user: UserModel, postCount: Int? = 0) {
        getCurrentUser()
        self.user = user
        profileEditButton.isHidden = user.userId != Auth.auth().currentUser?.uid
        followButton.isHidden = user.userId == Auth.auth().currentUser?.uid
        nickNameLabel.text = user.userNickName
        bioInfoLabel.text = user.bioInfo
        postCountLabel.text = "\(postCount ?? 0)"
        updateFollowers(user: user)
        
        if let url = URL(string: user.profilePhoto ?? "") {
            profilePhoto.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
            profilePhoto.setCornerRadius()
        }
    }
    
    private func getCurrentUser() {
        FirebaseManager.shared.fetchCurrentUserData { currentUser in
            self.currentUser = currentUser
        }
    }
    
    private func updateFollowers(user: UserModel) {
        followingLabel.text = "\(user.followingArray.count)"
        followersLabel.text = "\(user.followersArray.count)"
        updateFollowButton(user: user)
    }
    
    private func updateFollowButton(user: UserModel) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if user.followersArray.contains(uid) == false {
            followButton.setTitle("Takip et", for: .normal)
        } else {
            followButton.setTitle("Takibi birak", for: .normal)
        }
    }
    
    @IBAction func profileEditAction() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("Kullanıcı girmemiş")
            return
        }
        
        FirebaseManager.shared.fetchUsersData { [weak self] users in
            guard let self = self else { return }
            if let users = users {
                if let currentUser = users.first(where: { $0.userId == currentUserId }) {
                    self.showProfile?(currentUser)
                } else {
                    print("Kullanıcı bulunamadı.")
                }
            } else {
                print("Kullanıcı verileri alınamadı.")
            }
        }
    }
    
    @IBAction func followButtonTapped() {
        guard let userModel = user else { return }
        guard let currentUser = currentUser else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if userModel.followersArray.contains(uid) == true {
            userModel.followersArray.removeAll(where: { $0 == uid })
            followButton.setTitle("Takip et", for: .normal)
        } else {
            userModel.followersArray.append(uid)
            followButton.setTitle("Takibi birak", for: .normal)
        }
        FirebaseManager.shared.updateFollowersArray(userModel: userModel) { userData in
            if currentUser.followingArray.contains(userModel.userId ?? "") == true {
                currentUser.followingArray.removeAll(where: { $0 == userModel.userId })
            } else {
                currentUser.followingArray.append(userModel.userId ?? "")
            }
            guard let userDataModel = userData else { return }
            self.updateFollowers(user: userDataModel)
            FirebaseManager.shared.updateFollowingArray(userModel: currentUser) { model in
            }
        }
        
    }

    @IBAction func followersButtonAction() {
        delegate?.didTapFollowers(followerType: .follower)
    }
    
    @IBAction func followingsButtonAction() {
        delegate?.didTapFollowers(followerType: .following)  
    }

    func didUpdateUserData(user: UserModel) {
        configure(with: user)
    }
}
