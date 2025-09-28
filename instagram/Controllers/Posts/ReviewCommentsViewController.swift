//
//  ReviewCommentsViewController.swift
//  instagram
//
//  Created by Müge Deniz on 29.11.2024.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ReviewCommentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var commentTextView: UITextView!
    
    var postData: PostModel?
    var comments: [CommentModel]?
    var users: [UserModel]?
    var commentModel = CommentModel(dictionary: [:])

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        commentsTableView.dataSource = self
        commentsTableView.delegate = self
        commentsTableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentTableViewCell")
    }

    func setUI() {
        comments = postData?.commentDict
        commentsTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as! CommentTableViewCell
        guard let comment = comments?[indexPath.row] else { return UITableViewCell() }
        guard let user = users?.filter({ $0.userId == comment.userId }).first else { return UITableViewCell() }
        cell.setUI(userModel: user, commentModel: comment)
        return cell
    }
    
    @IBAction func closeButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func commentButton() {
        guard let commentText = commentTextView.text, !commentText.isEmpty else {
            print("Yorum metni boş olamaz.")
            return
        }
        let commentId = Helper.shared.generateRandomID(length: 20, isNumber: false)
        commentModel.commentText = commentText
        commentModel.userId = Auth.auth().currentUser?.uid ?? ""
        commentModel.commentId = commentId

        guard let postModel = postData else { return }
        
        FirebaseManager.shared.createComment(postModel: postModel, commentModel: commentModel) { [weak self] model in
            guard let self else { return }
            guard let model else { return }
            comments?.append(model)
            commentsTableView.reloadData()
            commentTextView.text = ""
        }
    }
}
