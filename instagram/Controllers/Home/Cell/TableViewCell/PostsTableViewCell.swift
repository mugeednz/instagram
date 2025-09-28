//
//  PostsTableViewCell.swift
//  instagram
//
//  Created by Müge Deniz on 3.11.2024.
//

import UIKit
import SDWebImage
import FirebaseAuth

protocol PostsTableViewCellDelegate: AnyObject {
    func didTapLikeCountLabel(postModel: PostModel)
    func didRequestDelete(postId: String)
    func didTapCommentButton(post: PostModel)
    func didTapProfile(userModel: UserModel)
}

class PostsTableViewCell: UITableViewCell {
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postBioLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var locationInfoLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var commentNumberLabel: UILabel!
    @IBOutlet weak var postImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var deleteButton: UIButton!
    weak var delegate: PostsTableViewCellDelegate?
    var likeCount = 0
    var postData = PostModel(dictionary: [:])
    var postId: String?
    var user: UserModel?
    
    func configure(with post: PostModel, user: UserModel) {
        self.postData = post
        self.user = user
        self.postId = post.postId
        saveButtonControl(postModel: post)
        postImageView.sd_setImage(with: URL(string: post.postPhoto.first ?? ""),
                                  placeholderImage: UIImage(named: "profilephoto")) {img,error,_,_ in
            let imageHeight = self.getImageAspectRatio(image: img ?? UIImage(),
                                                       cellImageFrame: self.frame.size)
            self.postImageViewHeight.constant = imageHeight
        }
        userNameLabel.text = user.userNickName
        userNameLabel.adjustsFontSizeToFitWidth = true
        userImageView.sd_setImage(with: URL(string: user.profilePhoto ?? ""),
                                  placeholderImage: UIImage(named: "profilephoto"))
        likeCountLabel.text = "\(post.likeArray.count)"
        
        if let locationInfo = post.locationInfo {
                locationInfoLabel.text = locationInfo.placeName
            }
        if post.newPostPhotoInfo?.isEmpty == false {
            postBioLabel.text = (user.userNickName ?? "") + " " + (post.newPostPhotoInfo ?? "")
        }
        if let userNickName = user.userNickName,
           let postInfo = post.newPostPhotoInfo,
           !postInfo.isEmpty {
            
            let fullText = "\(userNickName) \(postInfo)"
            let attributedString = NSMutableAttributedString(string: fullText)
            
            let boldRange = (fullText as NSString).range(of: userNickName)
            
            attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: postBioLabel.font.pointSize), range: boldRange)
            postBioLabel.attributedText = attributedString
        } else {
            postBioLabel.text = nil
        }
        likeButtonControl(postModel: post)
        setCornerRadius()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(likeCountLabelTapped))
        likeCountLabel.isUserInteractionEnabled = true
        likeCountLabel.addGestureRecognizer(tapGesture)
        let nameTapGesture = UITapGestureRecognizer(target: self, action: #selector(goToProfilePage))
           userNameLabel.isUserInteractionEnabled = true
           userNameLabel.addGestureRecognizer(nameTapGesture)
           
           let profileImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(goToProfilePage))
           userImageView.isUserInteractionEnabled = true
           userImageView.addGestureRecognizer(profileImageTapGesture)
    }
    func setCornerRadius() {
        userImageView.setCornerRadius(radius: 25)
    }
    @objc func goToProfilePage() {
        guard let user else { return }
        delegate?.didTapProfile(userModel: user)
    }
    @IBAction func likeButtonTapped(sender: UIButton) {
        FirebaseManager.shared.updateLikeArray(postModel: postData) { model in
            guard let model = model else { return }
            self.postData = model
            self.likeCountLabel.text = "\(model.likeArray.count)"
            self.likeButtonControl(postModel: model)
        }
    }
    
    func likeButtonControl(postModel: PostModel) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        if postModel.likeArray.contains(userId) == true {
            likeButton.setImage(UIImage(named: "heartfilled"), for: .normal)
        } else {
            likeButton.setImage(UIImage(named: "ic_like"), for: .normal)
        }
    }
    
    func getImageAspectRatio(image: UIImage, cellImageFrame: CGSize) -> CGFloat {
        let widthOffset = image.size.width - cellImageFrame.width
        let widthOffsetPerc = (widthOffset * 100) / image.size.width
        let heightOffset = (widthOffsetPerc * image.size.height) / 100
        let height = image.size.height - heightOffset
        return height
    }
    @IBAction func commentButtonTapped(){
        delegate?.didTapCommentButton(post: postData)
    }
        
    @IBAction func shareButtonTapped() {
        
    }

    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        guard let postId = postId else {
            print("Post ID bulunamadı.")
            return
        }
        delegate?.didRequestDelete(postId: postId)
    }
        
    @objc func likeCountLabelTapped() {
        delegate?.didTapLikeCountLabel(postModel: postData)
    }
    
    
    @IBAction func saveButtonTapped() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        FirebaseManager.shared.updateSaveArray(postModel: postData, userId: userId) { model in
            guard let model = model else { return }

            model.isSave = model.saveArray.contains(userId)

            self.postData = model
            self.saveButtonControl(postModel: model)
        }
    }
    func saveButtonControl(postModel: PostModel) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
 
        if postModel.saveArray.contains(userId) == true {
            saveButton.setImage(UIImage(named: "saved_full"), for: .normal)
        } else {
            saveButton.setImage(UIImage(named: "saved_empty"), for: .normal)
        }
    }

}


