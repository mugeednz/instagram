//
//  FollowersViewController.swift
//  instagram
//
//  Created by Müge Deniz on 9.12.2024.
//

import UIKit

enum FollowerType {
    case follower
    case following
}

class FollowersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var followersTableView: UITableView!
    var mainArray: [String]?
    var userModels: [UserModel]?
    var followerType: FollowerType = .follower
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllUser()
        followersTableView.delegate = self
        followersTableView.dataSource = self
        followersTableView.register(UINib(nibName: "LikesTableViewCell", bundle: nil), forCellReuseIdentifier: "LikesTableViewCell")
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func getAllUser() {
        FirebaseManager.shared.fetchUsersData { userModelData in
            self.userModels = userModelData
            self.followersTableView.reloadData()
        }
    }
    
    private func setUI() {
        switch followerType {
        case .follower:
            self.title = "Takipci"
        case .following:
            self.title = "Takip edilen"
        }
    }
    
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainArray?.count ?? 0
    }

    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LikesTableViewCell", for: indexPath) as! LikesTableViewCell
        if let user = userModels?.filter({ $0.userId == mainArray?[indexPath.row] }).first {
            cell.setUI(userModel: user)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

}
