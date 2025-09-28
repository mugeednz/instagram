//
//  ProfileButtomTableViewCell.swift
//  instagram
//
//  Created by Müge Deniz on 5.12.2024.
//

import UIKit
import FirebaseAuth

protocol ProfileButtomTableViewCellDelegate: AnyObject {
    func didTapPost(_ post: PostModel, index: Int?)
}

class ProfileButtomTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var profileCollectionView: UICollectionView!
    @IBOutlet weak var profileCollectionViewHeight: NSLayoutConstraint!
    var postList: [PostModel] = []
    var userId: String?
    weak var delegate: ProfileButtomTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileCollectionView.register(UINib(nibName: "ProfileCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProfileCollectionViewCell")
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        profileCollectionView.setCollectionViewLayout(layout, animated: true)
        profileCollectionView.delegate = self
        profileCollectionView.dataSource = self
    }
    
    func configure(with userId: String) {
        self.userId = userId
        fetchPosts()
    }
    
    private func updateCollectionHeight() {
        let height = profileCollectionView.collectionViewLayout.collectionViewContentSize.height
        profileCollectionViewHeight.constant = height
        profileCollectionView.layoutIfNeeded()
    }
    
    func fetchPosts() {
        guard let userId = userId else { return }
        
        FirebaseManager.shared.fetchPostData(userId: userId, lastTimestamp: nil, firstTimestamp: nil) { [weak self] posts in
            guard let self = self else { return }
            if let posts = posts {
                self.postList = posts.filter{ $0.userId == userId }
                self.profileCollectionView.reloadData()
                self.updateCollectionHeight()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCollectionViewCell", for: indexPath) as! ProfileCollectionViewCell
        let post = postList[indexPath.row]
        cell.configure(with: post)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPost = postList[indexPath.row]
        delegate?.didTapPost(selectedPost, index: indexPath.row)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize (width: (collectionView.frame.size.width - 2 ) / 3 , height: (collectionView.frame.size.width - 2 ) / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

