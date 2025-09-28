//
//  ProfileViewController.swift
//  instagram
//
//  Created by Müge Deniz on 3.12.2024.
//
import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ProfileButtomTableViewCellDelegate {
    
    @IBOutlet weak var profileTableView: UITableView!
    var user: UserModel?
    var users: [UserModel]?
    var postList: [PostModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileTableView.delegate = self
        profileTableView.dataSource = self
        profileTableView.register(UINib(nibName: "ProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfileTableViewCell")
        profileTableView.register(UINib(nibName: "ProfileButtomTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfileButtomTableViewCell")
        
        fetchUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func fetchUserData() {
        if user == nil {
            guard let currentUserId = Auth.auth().currentUser?.uid else { return }
            
            FirebaseManager.shared.fetchUsersData { [weak self] users in
                guard let self = self else { return }
                self.users = users
                if let users = users {
                    if let currentUser = users.first(where: { $0.userId == currentUserId }) {
                        self.user = currentUser
                        self.fetchPosts()
                        self.profileTableView.reloadData()
                    }
                }
            }
        } else {
            guard let currentUser = user else { return }
            didUpdateUserData(user: currentUser)
            fetchPosts()
        }
    }
    
    func fetchPosts() {
        guard let userId = user?.userId else { return }
        
        FirebaseManager.shared.fetchPostData(userId: userId, lastTimestamp: nil, firstTimestamp: nil) { [weak self] posts in
            guard let self = self else { return }
            if let posts = posts {
                self.postList = posts.filter { $0.userId == userId }
                DispatchQueue.main.async {
                    self.profileTableView.reloadData()
                }
            }
        }
    }
    
    func didTapPost(_ post: PostModel, index: Int? = 0) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let postDetailVC = storyboard.instantiateViewController(withIdentifier: "PostDetailViewController") as? PostDetailViewController {
            postDetailVC.userPosts = postList
            postDetailVC.user = user
            postDetailVC.users = users
            postDetailVC.index = index ?? 0
            navigationController?.pushViewController(postDetailVC, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell", for: indexPath) as! ProfileTableViewCell
            if let user = user {
                cell.configure(with: user, postCount: postList.count)
                cell.delegate = self
                cell.showProfile = { [weak self] currentUser in
                    guard let self = self else { return }
                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileEditViewController") as? ProfileEditViewController {
                        vc.delegate = self
                        vc.user = currentUser
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileButtomTableViewCell", for: indexPath) as! ProfileButtomTableViewCell
            if let userId = user?.userId {
                cell.delegate = self
                cell.configure(with: userId)
            }
            return cell
        }
    }
}

extension ProfileViewController: ProfileEditViewControllerDelegate {
    func didUpdateUserData(user: UserModel) {
        self.user = user
        self.profileTableView.reloadData()
    }
}
extension ProfileViewController: ProfileTableViewCellDelegate {
    func didTapFollowers(followerType: FollowerType) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let followersVC = storyboard.instantiateViewController(withIdentifier: "FollowersViewController") as? FollowersViewController {
            followersVC.followerType = followerType
            switch followerType {
            case .follower:
                followersVC.mainArray = user?.followersArray
            case .following:
                followersVC.mainArray = user?.followingArray
            }
            self.navigationController?.pushViewController(followersVC, animated: true)
        }
    }
    
    @IBAction func settingsButton() {

        let settingsVC = storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        navigationController?.pushViewController(settingsVC, animated: true)
    }
}


