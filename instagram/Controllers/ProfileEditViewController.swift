//
//  ProfileEditViewController.swift
//  instagram
//
//  Created by Müge Deniz on 6.11.2024.
//

import UIKit
import AVFoundation
import SDWebImage

protocol ProfileEditViewControllerDelegate: AnyObject {
    func didUpdateUserData(user: UserModel)
}
class ProfileEditViewController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var user: UserModel?
    weak var delegate: ProfileEditViewControllerDelegate?
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var biographyTextView: UITextView!
    @IBOutlet weak var biographyLabel: UILabel!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var surnameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileEditLabel: UILabel!
    @IBOutlet weak var NickNameLabel: UILabel!
    @IBOutlet weak var NickNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCornerRadius()
        setImageViewTap()
        checkCameraPermission()
        Helper.shared.showHud(text: "Lutfen bekleyiniz", view: view)
        fetchUserData()
        if let user = user {
            NickNameTextField.text = user.userNickName
            biographyTextView.text = user.bioInfo
            profileImageView.sd_setImage(with: URL(string: user.profilePhoto ?? ""),
                                              placeholderImage: UIImage(named: "profilePhoto"))
                          }
    }
    func fetchUserData() {
        FirebaseManager.shared.getUserData { userModel in
            self.NickNameTextField.text = userModel?.userNickName
            self.biographyTextView.text = userModel?.bioInfo
            self.nameTextField.text = userModel?.userName
            self.surnameTextField.text = userModel?.userSurname
            self.profileImageView.sd_setImage(with: URL(string: userModel?.profilePhoto ?? ""),
                                              placeholderImage: UIImage(named: "profilePhoto"))
            Helper.shared.hideHud()
        }
    }
    @objc func imageTapped(sender: UITapGestureRecognizer) {
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
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            profileImageView.image = selectedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func setImageViewTap() {
        let tapGr = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
        profileImageView.addGestureRecognizer(tapGr)
        profileImageView.isUserInteractionEnabled = true
    }
    func openSettings() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }
    }
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("Kamera izni verildi.")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { response in
                if response {
                    print("Kamera izni verildi.")
                } else {
                    print("Kamera izni verilmedi.")
                }
            }
        case .denied, .restricted:
            print("Kamera izni reddedildi.")
        @unknown default:
            break
        }
    }
    func setCornerRadius() {
        profileImageView.setCornerRadius(radius: 60)
        
    }
    @IBAction func closeButtonAction() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    
    @IBAction func uploadButtonAction() {
        guard let data = profileImageView.image?.jpegData(compressionQuality: 1) else { return }
        var userModel = UserModel(dictionary: [:])
        Helper.shared.showHud(text: "", view: view)
        FirebaseManager.shared.uploadUserProfilePic(imageData: data) { urlStr in
            userModel.userName = self.nameTextField.text
            userModel.bioInfo = self.biographyTextView.text
            userModel.userNickName = self.NickNameTextField.text
            userModel.userSurname = self.surnameTextField.text
            userModel.profilePhoto = urlStr
            FirebaseManager.shared.userUpdate(userModel: (userModel))
            Helper.shared.hideHud()
        }
        self.delegate?.didUpdateUserData(user: userModel)
        
        self.closeButtonAction()

    }
}
