//
//  HomeViewController.swift
//  instagram
//
//  Created by Müge Deniz on 3.11.2024.
//
import UIKit
import FirebaseAuth
import AVFoundation
import FirebaseDatabase
import ESPullToRefresh

class HomeViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, CreatePostDelegate, PostsTableViewCellDelegate  {
    
    @IBOutlet weak var postTableView: UITableView!
    var selectedUser: UserModel?
    var posts: [PostModel] = []
    var users: [UserModel] = []
    var userPostData: [UserPostModel] = []
    private var isFetchingPosts = false
    private var lastPostTimestamp: String?
    private var isNewStory = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        fetchUserData()
        postTableView.delegate = self
        postTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setTableView() {
        postTableView.dataSource = self
        postTableView.delegate = self
        postTableView.register(UINib(nibName: "StoriesTableViewCell", bundle: nil), forCellReuseIdentifier: "StoriesTableViewCell")
        postTableView.register(UINib(nibName: "PostsTableViewCell", bundle: nil), forCellReuseIdentifier: "PostsTableViewCell")
        postTableView.es.addPullToRefresh {
            [unowned self] in
            fetchUserData(isNewPost: true)
            postTableView.es.stopPullToRefresh()
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
            
            if let index = self.posts.firstIndex(where: { $0.postId == postId }) {
                self.posts.remove(at: index)
                self.postTableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Hayır", style: .cancel, handler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func cameraButton() {
        cameraButtonTapped()
    }
    
    private func showUserStory(user: UserModel) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let createStoryVC = storyboard.instantiateViewController(withIdentifier: "OpenStoryViewController") as? OpenStoryViewController {
            createStoryVC.modalPresentationStyle = .overFullScreen
            createStoryVC.user = user
            self.present(createStoryVC, animated: true, completion: nil)
        }
    }
    func showCreateStoryPopup(for userModel: UserModel) {
        let alertController = UIAlertController(title: "Hikaye Seçeneği", message: "Hikayenizi oluşturmak ister misiniz?", preferredStyle: .alert)
        
        let createAction = UIAlertAction(title: "Story Oluştur", style: .default) { _ in
            self.isNewStory = true
            self.cameraButtonTapped()
        }
        
        let viewAction = UIAlertAction(title: "Story Görüntüle", style: .default) { _ in
            self.showUserStory(user: userModel)
        }
        
        let cancelAction = UIAlertAction(title: "İptal", style: .cancel, handler: nil)
        
        alertController.addAction(createAction)
        alertController.addAction(viewAction)
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func cameraButtonTapped() {
        let alert = UIAlertController(title: "Fotoğraf Kaynağını Seç", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Kamera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Galeriden Seç", style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        } else {
            print("Kamera kullanılamıyor.")
        }
    }
    
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        } else {
            print("Galeri kullanılamıyor.")
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            picker.dismiss(animated: true, completion: {
                if self.isNewStory {
                    self.isNewStory = false
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let createStoryVC = storyboard.instantiateViewController(withIdentifier: "CreateStoryViewController") as? CreateStoryViewController {
                        createStoryVC.userModel = self.selectedUser
                        createStoryVC.selectedImage = selectedImage
                        createStoryVC.modalPresentationStyle = .overFullScreen
                        createStoryVC.reloadUserData = { model in
                            self.selectedUser = model
                            self.postTableView.reloadData()
                        }
                        self.present(createStoryVC, animated: true, completion: nil)
                    }
                } else {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let createPostVC = storyboard.instantiateViewController(withIdentifier: "CreatePostViewController") as? CreatePostViewController {
                        createPostVC.selectedImage = selectedImage
                        createPostVC.modalPresentationStyle = .overFullScreen
                        createPostVC.delegate = self
                        self.present(createPostVC, animated: true, completion: nil)
                    }
                }
            })
        } else {
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func fetchPostData() {
        let userId = self.selectedUser?.userId ?? Auth.auth().currentUser?.uid
        
        FirebaseManager.shared.fetchPostData(userId: userId, lastTimestamp: lastPostTimestamp, firstTimestamp: nil) { [weak self] postModelData in
            guard let self = self else { return }
            self.isFetchingPosts = false
            
            if let newPosts = postModelData, !newPosts.isEmpty {
                self.posts.append(contentsOf: newPosts)
                self.posts = Dictionary(grouping: self.posts, by: { $0.postId }).compactMap { $0.value.first }
                self.posts = self.posts.sorted(by: { $0.timestamp ?? "" > $1.timestamp ?? "" })
                self.lastPostTimestamp = newPosts.last?.timestamp
                
                DispatchQueue.main.async {
                    self.postTableView.reloadData()
                }
            } else {
                print("Daha fazla gönderi yok.")
            }
            Helper.shared.hideHud()
        }
    }
    
    func fetchNewPostData() {
        let userId = self.selectedUser?.userId ?? Auth.auth().currentUser?.uid
        let firstTimestamp = self.posts.first?.timestamp
        
        FirebaseManager.shared.fetchPostData(userId: userId, lastTimestamp: nil, firstTimestamp: firstTimestamp) { [weak self] postModelData in
            guard let self = self else { return }
            if let newPosts = postModelData, !newPosts.isEmpty {
                self.posts.insert(contentsOf: newPosts, at: 0)
                self.posts = Dictionary(grouping: self.posts, by: { $0.postId }).compactMap { $0.value.first }
                self.posts = self.posts.sorted(by: { $0.timestamp ?? "" > $1.timestamp ?? "" })
                DispatchQueue.main.async {
                    self.postTableView.reloadData()
                }
            } else {
                print("Daha fazla gönderi yok.")
            }
            Helper.shared.hideHud()
        }
    }
    
    
    func fetchUserData(isNewPost: Bool = false) {
        Helper.shared.showHud(text: "", view: view)
        FirebaseManager.shared.fetchUsersData { [weak self] userModelData in
            guard let self = self else { return }
            
            self.users = userModelData ?? []
            
            if let currentUserId = Auth.auth().currentUser?.uid {
                self.selectedUser = self.users.first(where: { $0.userId == currentUserId })
            }
            
            if isNewPost {
                self.fetchNewPostData()
            } else {
                self.fetchPostData()
            }
        }
    }
    
    
    func refreshPage() {
        Helper.shared.showHud(text: "", view: view)
        fetchUserData()
    }
    @IBAction func messageButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let messageVC = storyboard.instantiateViewController(withIdentifier: "MessageViewController") as? MessageViewController {
            self.navigationController?.pushViewController(messageVC, animated: true)
        }
    }
    
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  posts.count + 1 //selectedUser?.followingArray.count ?? 0 + 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StoriesTableViewCell", for: indexPath) as! StoriesTableViewCell
            cell.fillUserData(users: users)
            cell.showCreateStoryPopup = { [weak self] user in
                self?.showCreateStoryPopup(for: user)
            }
            cell.showStory = { model in
                self.showUserStory(user: model)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostsTableViewCell", for: indexPath) as! PostsTableViewCell
            let post = posts[indexPath.row - 1]
            guard let user = users.filter({ $0.userId == post.userId }).first else { return UITableViewCell() }
            cell.configure(with: post, user: user)
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 150
        }
        return UITableView.automaticDimension
    }
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == postTableView {
            let position = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let frameHeight = scrollView.frame.size.height
            
            if position > contentHeight - frameHeight - 100 {
                fetchUserData()
            }
        }
    }
}

