//
//  StoriesTableViewCell.swift
//  instagram
//
//  Created by Müge Deniz on 23.11.2024.
//

import UIKit
import FirebaseAuth

class StoriesTableViewCell: UITableViewCell {
    @IBOutlet weak var storyCollectionView: UICollectionView!
    var users: [UserModel] = []
    var user: UserModel?
    var showImagePicker: ((_ userModel: UserModel,_ isNewStory: Bool) -> Void)?
    var showStory: ((_ selectedUser: UserModel) -> Void)?
    var showCreateStoryPopup: ((_ selectedUser: UserModel) -> Void)? 
    override func awakeFromNib() {
        super.awakeFromNib()
        set()
    }
    
    func set() {
        setupStoryCollectionView()
    }
    func fillUserData(users: [UserModel]) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        if let currentUser = users.first(where: { $0.userId == userId }) {
            self.users = [currentUser]
            let otherUsers = users.filter { $0.userId != userId && $0.userStory.isEmpty == false }
            self.users.append(contentsOf: otherUsers)
        }
        
        storyCollectionView.reloadData()
    }

    private func setupStoryCollectionView() {
        storyCollectionView.dataSource = self
        storyCollectionView.delegate = self
        storyCollectionView.register(UINib(nibName: "StoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StoryCollectionViewCell")
        setupCollectionViewCellLayout()
    }
    
    func setupCollectionViewCellLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.scrollDirection = .horizontal
        storyCollectionView.showsHorizontalScrollIndicator = false
        storyCollectionView.setCollectionViewLayout(layout, animated: true)
    }
}

extension StoriesTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCollectionViewCell", for: indexPath) as! StoryCollectionViewCell
        cell.configure(with: users[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let selectedUser = users[indexPath.row]

            if selectedUser.userId == Auth.auth().currentUser?.uid {
                self.showCreateStoryPopup?(selectedUser)
            } else {
                self.showStory?(selectedUser)
            }
        }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
