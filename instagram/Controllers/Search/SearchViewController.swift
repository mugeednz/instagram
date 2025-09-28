//
//  SearchViewController.swift
//  instagram
//
//  Created by Müge Deniz on 30.11.2024.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var allUsers: [UserModel]?
    var searchedUsers: [UserModel]?
    var isSearchActive = false
    var searchText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        searchTableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchTableViewCell");
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        getUsersData()
        setupSearchTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    func setupSearchTextField() {
        searchTextField.layer.cornerRadius = 12
        searchTextField.layer.masksToBounds = true
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func getUsersData() {
        FirebaseManager.shared.fetchUsersData { users in
            self.allUsers = users
            self.searchedUsers = users
            self.searchTableView.reloadData()
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let query = textField.text?.lowercased() ?? ""
        
        if query.isEmpty {
            isSearchActive = false
            searchedUsers = allUsers
        } else if query.count >= 2 {
            isSearchActive = true
            searchedUsers = allUsers?.filter { $0.userNickName?.lowercased().contains(query) ?? false }
        } else {
            isSearchActive = false
        }
        
        searchTableView.reloadData()
    }
    
    func saveSearchHistory(term: String) {
        guard !term.isEmpty else { return }
        var history = UserDefaults.standard.stringArray(forKey: "searchHistory") ?? []
        
        if !history.contains(term) {
            history.insert(term, at: 0)
            UserDefaults.standard.set(history, forKey: "searchHistory")
        }
    }
    func loadSearchHistory() -> [String] {
        return UserDefaults.standard.stringArray(forKey: "searchHistory") ?? []
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchActive ? (searchedUsers?.count ?? 0) : loadSearchHistory().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearchActive {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as! SearchTableViewCell
            if let user = searchedUsers?[indexPath.row] {
                cell.setUI(userModel: user)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
            let history = loadSearchHistory()
            cell.textLabel?.text = history[indexPath.row]
            cell.textLabel?.textColor = .darkGray
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearchActive {
            if let selectedUser = searchedUsers?[indexPath.row] {
                saveSearchHistory(term: selectedUser.userNickName ?? "")
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
                    profileVC.user = selectedUser
                    navigationController?.pushViewController(profileVC, animated: true)
                }
            }
        } else {
            let history = loadSearchHistory()
            searchTextField.text = history[indexPath.row]
            textFieldDidChange(searchTextField)
        }
    }
    
}

