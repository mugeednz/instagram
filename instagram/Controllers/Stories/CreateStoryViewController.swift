//
//  CreateStoryViewController.swift
//  instagram
//
//  Created by Müge Deniz on 24.11.2024.
//

import UIKit
import FirebaseStorage
import FirebaseAuth

class CreateStoryViewController: UIViewController {
    var selectedImage: UIImage?
    @IBOutlet weak var storyImageView: UIImageView!
    var userModel: UserModel?
    var reloadUserData: ((_ userModel: UserModel) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        storyImageView.image = selectedImage
    }
    
    @IBAction func logoutButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createButtonAction() {
        guard let selectedImage = storyImageView.image else {
            print("Image is not available in the image view.")
            return
        }
        
        Helper.shared.showHud(text: "Güncelleniyor", view: view)
        
        FirebaseManager.shared.uploadStoryToStorage(image: selectedImage) { storyURL in
            guard let storyURL = storyURL else {
                print("Failed to get the story URL.")
                Helper.shared.hideHud()
                return
            }
            guard let userModel = self.userModel else { return }
            FirebaseManager.shared.updateUserStory(userModel: userModel, storyUrl: storyURL) { model in
                guard let model = model else {return }
                Helper.shared.hideHud()
                self.dismiss(animated: true) {
                    self.reloadUserData?(model)
                }
            }
        }
    }
}
