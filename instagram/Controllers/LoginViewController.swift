//
//  LoginViewController.swift
//  instagram
//
//  Created by Müge Deniz on 30.10.2024.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, DataDelegate, UITextFieldDelegate {
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func setUI() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Uyarı", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @IBAction func loginButtonAction() {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        if email.isEmpty && password.isEmpty {
            showAlert(message: "Lütfen e-posta ve şifreyi girin.")
        }
        guard let mail = emailTextField.text, !mail.isEmpty else {
            showAlert(message: "E-posta adresini girin.")
            return }
        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Şifreyi girin.")
            return}
        if mail.isValidEmail() {
            Auth.auth().signIn(withEmail: mail, password: password) { [weak self] authResult, error in
              guard let self = self else { return }
                if error != nil {
                    self.registerButtonAction()
                }
            }
        } else {
            showAlert(message: "gecerli bir mail gir")
        }
    }
    @IBAction func registerButtonAction() {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController
        vc?.delegate = self
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func passData(mail: String) {
        emailTextField.text = mail
    }
}

