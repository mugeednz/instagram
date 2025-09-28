//
//  ReviewLikeViewController.swift
//  instagram
//
//  Created by Müge Deniz on 19.11.2024.
//

import UIKit

class ReviewLikeViewController: UIViewController {
    @IBOutlet weak var likesTableView: UITableView!
    var postData: PostModel?
    var userData: [UserModel]?

    override func viewDidLoad() {
        super.viewDidLoad()
        likesTableView.delegate = self
        likesTableView.dataSource = self
        likesTableView.register(UINib(nibName: "LikesTableViewCell", bundle: nil), forCellReuseIdentifier: "LikesTableViewCell")
    }
}

extension ReviewLikeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postData?.likeArray.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LikesTableViewCell", for: indexPath) as! LikesTableViewCell
        guard let user = (userData?.filter { $0.userId == postData?.likeArray[indexPath.row] }.first) else { return UITableViewCell() }
        cell.setUI(userModel: user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    @IBAction func closeButton() {
        self.navigationController?.popViewController(animated: true)
    }
}





