//
//  RegisterViewController.swift
//  instagram
//
//  Created by Müge Deniz on 30.10.2024.
//

import UIKit
import FirebaseAuth

protocol DataDelegate {
    func passData(mail: String)
}
class RegisterViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButtton: UIButton!
    var delegate: DataDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setUI()
    }
    func setUI() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @IBAction func registerButtonAction() {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        if email.isEmpty && password.isEmpty {
            showAlert(message: "Lütfen e-posta ve şifre girin.")
        }
        guard let mail = emailTextField.text, !mail.isEmpty else {
            showAlert(message: "E-posta adresini girin.")
            return }
        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Şifreyi girin.")
            return}
        if mail.isValidEmail() {
            Auth.auth().createUser(withEmail: mail, password: password) { authResult, error in
                if error != nil {
                    self.showAlert(message: error?.localizedDescription ?? "")
                    return
                }
                let userModel = UserModel(dictionary: [:])
                FirebaseManager.shared.createUserToFirebase(userModel: userModel)
            }
        } else {
            showAlert(message: "Lutfen gecerli bir mail giriniz")
        }
    }
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Uyarı", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    @IBAction func loginButton() {
        navigationController?.popViewController(animated: true)
    }
}
