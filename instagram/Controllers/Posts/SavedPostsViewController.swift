//
//  SavedPostsViewController.swift
//  instagram
//
//  Created by Müge Deniz on 23.12.2024.
//
import UIKit
import FirebaseAuth
import FirebaseDatabase

class SavedPostsViewController: UIViewController, PostsTableViewCellDelegate {
    
    @IBOutlet weak var savedTableView: UITableView!
    var savedPosts: [PostModel]?
    var users: [UserModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        savedTableView.delegate = self
        savedTableView.dataSource = self
        savedTableView.register(UINib(nibName: "PostsTableViewCell", bundle: nil), forCellReuseIdentifier: "PostsTableViewCell")
        
        savedTableView.separatorStyle = .none
        savedTableView.rowHeight = UITableView.automaticDimension
        savedTableView.estimatedRowHeight = 600
        
        getAllUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func fetchSavedPosts() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        FirebaseManager.shared.fetchPostData(userId: currentUserId, lastTimestamp: "", firstTimestamp: "") { postModelData in
            self.savedPosts = postModelData?.filter{ $0.saveArray.contains(currentUserId) == true }
            self.savedTableView.reloadData()
        }
    }
    
    private func getAllUser() {
        FirebaseManager.shared.fetchUsersData { userModelData in
            self.users = userModelData
            self.fetchSavedPosts()
        }
    }
    func didTapLikeCountLabel(postModel: PostModel) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let reviewVC = storyboard.instantiateViewController(withIdentifier: "ReviewLikeViewController") as? ReviewLikeViewController {
            reviewVC.postData = postModel
            reviewVC.userData = users
            navigationController?.pushViewController(reviewVC, animated: true)
        }
    }
    
    func didRequestDelete(postId: String) {
        print("Delegate metodu çağrıldı, Post ID: \(postId)")
        showDeleteConfirmation(postId: postId)
    }
    
    func didTapCommentButton(post: PostModel) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let reviewCommentsVC = storyboard.instantiateViewController(withIdentifier: "ReviewCommentsViewController") as? ReviewCommentsViewController {
            reviewCommentsVC.postData = post
            reviewCommentsVC.users = users
            navigationController?.pushViewController(reviewCommentsVC, animated: true)
        }
    }
    
    func didTapProfile(userModel: UserModel) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
            profileVC.user = userModel
            navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    func showDeleteConfirmation(postId: String) {
        print("Silme onayı için alert gösteriliyor.")
        let alertController = UIAlertController(title: "Onay",
                                                message: "Bu gönderiyi silmek istediğinizden emin misiniz?",
                                                preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Evet", style: .destructive) { _ in
            print("Silme işlemi onaylandı, PostId: \(postId)")
            
            FirebaseManager.shared.deletePost(postId: postId)
            
            if let index = self.savedPosts?.firstIndex(where: { $0.postId == postId }) {
                self.savedPosts?.remove(at: index)
                self.savedTableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Hayır", style: .cancel, handler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension SavedPostsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedPosts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostsTableViewCell", for: indexPath) as? PostsTableViewCell else {
            return UITableViewCell()
        }
        guard let post = savedPosts?[indexPath.row] else { return UITableViewCell() }
        guard let user = users?.filter({ post.userId == $0.userId }).first else { return UITableViewCell() }
        cell.configure(with: post, user: user)
        cell.delegate = self
        return cell
    }
}
