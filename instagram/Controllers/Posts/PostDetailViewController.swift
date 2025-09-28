//
//  PostDetailViewController.swift
//  instagram
//
//  Created by Müge Deniz on 9.12.2024.
//

import UIKit

class PostDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PostsTableViewCellDelegate {
    
    @IBOutlet weak var postTableView: UITableView!
    var user: UserModel?
    var users: [UserModel]?
    var userPosts: [PostModel]?
    var index = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        postTableView.delegate = self
        postTableView.dataSource = self
        postTableView.register(UINib(nibName: "PostsTableViewCell", bundle: nil), forCellReuseIdentifier: "PostsTableViewCell")
        
        postTableView.separatorStyle = .none
        postTableView.rowHeight = UITableView.automaticDimension
        postTableView.estimatedRowHeight = 600
        DispatchQueue.main.async {
            self.postTableView.scrollToRow(at: IndexPath(row: self.index, section: 0), at: .middle, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userPosts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostsTableViewCell", for: indexPath) as? PostsTableViewCell else {
            return UITableViewCell()
        }
        guard let user else { return UITableViewCell() }
        guard let post = userPosts?[indexPath.row] else { return UITableViewCell() }
        cell.configure(with: post, user: user)
        cell.delegate = self
        return cell
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
            
            if let index = self.userPosts?.firstIndex(where: { $0.postId == postId }) {
                self.userPosts?.remove(at: index)
                self.postTableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Hayır", style: .cancel, handler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}



