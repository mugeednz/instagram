//
//  SettingsViewController.swift
//  instagram
//
//  Created by Müge Deniz on 12.12.2024.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    let settingsOptions = [("Kaydedilenler", UIImage(systemName: "bookmark")),
                           ("Profil Düzenle", UIImage(systemName: "person.circle")),
                           ("Çıkış Yap", UIImage(systemName: "arrow.right.circle"))]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsTableViewCell")
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

    func setUI() {
        title = "Ayarlar"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsOptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath) as! SettingsTableViewCell
        let option = settingsOptions[indexPath.row]
        cell.configure(option: option.0, icon: option.1)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            let savedVC = storyboard?.instantiateViewController(withIdentifier: "SavedPostsViewController") as! SavedPostsViewController
            navigationController?.pushViewController(savedVC, animated: true)
        case 1:
            let profileEditVC = storyboard?.instantiateViewController(withIdentifier: "ProfileEditViewController") as! ProfileEditViewController
            navigationController?.pushViewController(profileEditVC, animated: true)
        case 2:
            showLogoutAlert()
        default:
            break
        }
    }
    
    func showLogoutAlert() {
        let alert = UIAlertController(title: "Çıkış Yap", message: "Hesabınızdan çıkış yapmak istediğinizden emin misiniz?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Çıkış Yap", style: .destructive, handler: { _ in
            self.logoutUser()
        }))
        present(alert, animated: true, completion: nil)
    }

    func logoutUser() {
        do {
            try Auth.auth().signOut()
            if let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
                loginVC.modalPresentationStyle = .fullScreen
                present(loginVC, animated: true, completion: nil)
            }
        } catch {
            print("Çıkış yaparken hata oluştu: \(error.localizedDescription)")
        }
    }
}
