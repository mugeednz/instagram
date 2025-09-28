//
//  SplashViewController.swift
//  instagram
//
//  Created by Müge Deniz on 2.11.2024.
//

import UIKit
import FirebaseAuth

class SplashViewController: UIViewController {    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let _ = Auth.auth().addStateDidChangeListener { auth, user in
            if user == nil {
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
                self.navigationController?.pushViewController(vc!, animated: true)
            } else {
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "InstaTabBarController") as? InstaTabBarController
                self.navigationController?.pushViewController(vc!, animated: true)
            }
        }
    }
}
