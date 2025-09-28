//  MessageViewController.swift
//  instagram
//
//  Created by Müge Deniz on 11.12.2024.

import UIKit
import FirebaseFirestore
import FirebaseAuth

class MessageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var messageListTableView: UITableView!
    var users: [UserModel]?
    var currentUser: UserModel?
    var channels = [Channel]()
    var channelListener: ListenerRegistration?
    var db = Firestore.firestore()
    var channelRef: CollectionReference {
        return db.collection("channels")
    }
    var isNewChat = false
    var newChatUserModel: UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        getChannelInfo()
        getCurrentUser()
        configureNavigationBar()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewMessageButtonTapped)
        )
    }

    @objc private func addNewMessageButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let newMessageVC = storyboard.instantiateViewController(withIdentifier: "NewMessageViewController") as? NewMessageViewController {
            newMessageVC.onUserSelected = { [weak self] selectedUser in
                guard let self else { return }
                self.addNewMessage(userModel: selectedUser)
            }
            self.present(newMessageVC, animated: true, completion: nil)
        }
    }
    
    private func setTableView() {
        messageListTableView.dataSource = self
        messageListTableView.delegate = self
        messageListTableView.register(UINib(nibName: "MessageListTableViewCell", bundle: nil), forCellReuseIdentifier: "MessageListTableViewCell")
    }
    
    private func getAllUsers() {
        FirebaseManager.shared.fetchUsersData { userModelData in
            self.users = userModelData
            self.messageListTableView.reloadData()
        }
    }
    
    private func getCurrentUser() {
        FirebaseManager.shared.getUserData { user in
            self.currentUser = user
            self.getAllUsers()
        }
    }
    
    private func getChannelInfo() {
        channelListener = channelRef.addSnapshotListener { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            snapshot?.documentChanges.forEach { change in
                self.handleDocumentChange(change: change)
            }
        }
    }
    
    private func handleDocumentChange(change: DocumentChange) {
        guard let channel = Channel(document: change.document) else { return }
        
        switch change.type {
        case .added:
            addChannelToTable(channel: channel)
        case .modified:
            print("Channel modified")
        case .removed:
            removeChannelFromTable(channel: channel)
        }
    }
    
    private func addChannelToTable(channel: Channel) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard !channels.contains(channel) else { return }
        if channel.otherUserId?.contains(currentUid) == true {
            channels.append(channel)
            channels.sort { $0.name < $1.name }
            messageListTableView.reloadData()
        }
    }
    
    private func removeChannelFromTable(channel: Channel) {
        guard let index = channels.firstIndex(of: channel) else { return }
        channels.remove(at: index)
        messageListTableView.reloadData()
    }
    
    private func addNewMessage(userModel: UserModel) {
        if let userChannel = self.channels.filter({ $0.otherUserId?.contains(userModel.userId ?? "") == true }).first {
            self.openChatWithUser(channel: userChannel, userModel: userModel)
        } else {
            let currentUid = Auth.auth().currentUser?.uid
            let channel = Channel(name: userModel.userNickName ?? "", otherUserId: ["\(userModel.userId ?? "")", "\(currentUid ?? "")"])
            channelRef.addDocument(data: channel.representation) { error in
                if let error = error {
                    print("Kanal eklenirken hata: \(error.localizedDescription)")
                } else {
                    print("Yeni kanal başarıyla eklendi.")
                    self.isNewChat = true
                    if self.isNewChat {
                        self.isNewChat = false
                        guard let userId = userModel.userId else { return }
                        guard let userChannel = self.channels.filter({ $0.otherUserId?.contains(userId) == true }).first else { return }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.openChatWithUser(channel: userChannel, userModel: userModel)
                        }
                    }
                }
            }
        }
    }
    
    private func openChatWithUser(channel: Channel, userModel: UserModel) {
        let chatVC = ChatDetailViewController(user: Auth.auth().currentUser!, channel: channel)
        navigationController?.pushViewController(chatVC, animated: true)
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageListTableViewCell", for: indexPath) as? MessageListTableViewCell else {
            return UITableViewCell()
        }
        
        let channel = channels[indexPath.row]
        guard let otherUserId = channel.otherUserId?.first(where: { $0 != Auth.auth().currentUser?.uid }) else {
            return UITableViewCell()
        }
        
        if let otherUser = users?.first(where: { $0.userId == otherUserId }) {
            cell.setUIList(userModel: otherUser)
        } else {
            print("Kullanıcı bulunamadı: \(otherUserId)")
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = ChatDetailViewController(user: Auth.auth().currentUser!, channel: channels[indexPath.row])
        navigationController?.pushViewController(chatVC, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}


