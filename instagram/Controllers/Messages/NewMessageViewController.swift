//
//  NewMessageViewController.swift
//  instagram
//
//  Created by Müge Deniz on 16.12.2024.
//

import UIKit

class NewMessageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var exploreTableView: UITableView!
    @IBOutlet weak var exploreTextField: UITextField!
    
    var allUsers: [UserModel]?
    var exploredUsers: [UserModel]?
    var isSearchActive = false
    var exploreText = ""
    var selectedUser: UserModel?
    var onUserSelected: ((UserModel) -> Void)? 

    
    override func viewDidLoad() {
        super.viewDidLoad()
        exploreTableView.delegate = self
        exploreTableView.dataSource = self
        exploreTableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchTableViewCell");
        exploreTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        getUsersData()
        setupSearchTextField()
        if let user = selectedUser {
            print("Selected user: \(user.userNickName)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    func setupSearchTextField() {
        exploreTextField.layer.cornerRadius = 12
        exploreTextField.layer.masksToBounds = true
        exploreTextField.layer.borderWidth = 1
        exploreTextField.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func getUsersData() {
        FirebaseManager.shared.fetchUsersData { users in
            self.allUsers = users
            self.exploredUsers = users
            self.exploreTableView.reloadData()
        }
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let query = textField.text?.lowercased() else { return }
        exploredUsers = allUsers?.filter { $0.userNickName?.lowercased().contains(query) ?? false }
        exploreTableView.reloadData()
    }
    
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exploredUsers?.count ?? 0    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as! SearchTableViewCell
        if let user = exploredUsers?[indexPath.row] {
            cell.setUI(userModel: user)        }
        return cell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedUser = exploredUsers?[indexPath.row] else { return }
        dismiss(animated: true) {
            self.onUserSelected?(selectedUser)
        }
    }

}
