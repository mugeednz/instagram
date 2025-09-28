//
//  FirebaseManager.swift
//  instagram
//
//  Created by Müge Deniz on 6.11.2024.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import CodableFirebase

class FirebaseManager {
    static let shared = FirebaseManager()
    private var databaseRef: DatabaseReference?
    init() {
        databaseRef = Database.database().reference()
    }
    
    func createUserToFirebase(userModel: UserModel) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let userDict: [String: Any] = [
            "userId": userId,
            "userName": userModel.userName ?? "",
            "userSurname": userModel.userSurname ?? "",
            "profilePhoto": userModel.profilePhoto ?? "",
            "followersArray": userModel.followersArray ?? [],
            "followingArray": userModel.followingArray ?? [],
            "bioInfo": userModel.bioInfo ?? "",
            "userNickName": userModel.userNickName ?? "",
            "userStory": userModel.userStory ?? [],
        ]
        
        databaseRef?.child("Users").child(userId).setValue(userDict) { error, _ in
            if let error = error {
                print("Veri kaydetme hatası: \(error.localizedDescription)")
            } else {
                print("Kullanıcı başarıyla kaydedildi!")
            }
        }
    }
    
    func uploadUserProfilePic(imageData: Data, completion: @escaping(_ url: String?) -> Void){
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let filePath = "UserPhoto/\(userId)/pp.png"
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        let storageRef = Storage.storage().reference()
        storageRef.child(filePath).putData(imageData, metadata: metaData) { (data, error) in
            if error != nil {
                completion(error?.localizedDescription)
            } else {
                storageRef.child(filePath).downloadURL { (url, error) in
                    if error != nil {
                        completion("")
                    } else {
                        completion(url?.absoluteString)
                    }
                }
            }
        }
    }
    func createPostPhoto(postModel: PostModel, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let locationInfoDict = postModel.locationInfo?.toDictionary() ?? [:]
        
        let postDict: [String: Any] = [
            "userId": userId,
            "postId": postModel.postId,
            "postInfo": postModel.newPostPhotoInfo ?? "",
            "postPhoto": postModel.postPhoto,
            "likeArray": postModel.likeArray,
            "timestamp": postModel.timestamp ?? "",
            "commentList": postModel.commentDict.map { _ in [CommentModel]() },
            "locationInfo": locationInfoDict
        ]
        
        let databaseRef = self.databaseRef?.child("Posts").child(postModel.postId)
        databaseRef?.setValue(postDict) { error, _ in
            if let error = error {
                print("Veri güncellenemedi: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Veri başarıyla güncellendi.")
                completion(true)
            }
        }
    }
    
    func uploadUserPostPic(imageData: Data, completion: @escaping(_ url: String?) -> Void){
        let photoName = Helper.shared.generateRandomID(length: 15, isNumber: true)
        let filePath = "UserPhoto/Muge/\(photoName).png"
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        let storageRef = Storage.storage().reference()
        storageRef.child(filePath).putData(imageData, metadata: metaData) { (data, error) in
            if error != nil {
                completion(error?.localizedDescription)
            } else {
                storageRef.child(filePath).downloadURL { (url, error) in
                    if error != nil {
                        completion("")
                    } else {
                        completion(url?.absoluteString)
                    }
                }
            }
        }
    }
    func getUserData(completion: @escaping(_ userModelData: UserModel?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userRef = databaseRef?.child("Users").child(userId)
        userRef?.observeSingleEvent(of: .value, with: { snapshot in
            guard let userData = snapshot.value as? [String: Any] else { return }
            let userModel = UserModel(dictionary: userData as NSDictionary)
            completion(userModel)
        }) { error in
            print("Veri çekilirken hata oluştu: \(error.localizedDescription)")
        }
    }
    func updateLikeArray(postModel: PostModel, completion: @escaping (PostModel?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        var likeArray = postModel.likeArray
        
        if likeArray.contains(userId) {
            likeArray.removeAll(where: { $0 == userId })
        } else {
            likeArray.append(userId)
        }
        
        databaseRef?.child("Posts").child(postModel.postId).child("likeArray").setValue(likeArray) { error, ref in
            if let error = error {
                print("Failed to update likeArray: \(error.localizedDescription)")
                completion(nil)
            } else {
                var updatedPostModel = postModel
                updatedPostModel.likeArray = likeArray
                completion(updatedPostModel)
            }
        }
    }
    
    func userUpdate(userModel: UserModel) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let userDict: [String: Any] = [
            "userId": userId,
            "userName": userModel.userName ?? "",
            "userSurname": userModel.userSurname ?? "",
            "profilePhoto": userModel.profilePhoto ?? "",
            "followersArray": userModel.followersArray ?? [],
            "followingArray": userModel.followingArray ?? [],
            "bioInfo": userModel.bioInfo ?? "",
            "userNickName": userModel.userNickName ?? "",
            "userStory": userModel.userStory ?? [],
        ]
        
        let databaseRef = Database.database().reference().child("Users").child(userId)
        
        databaseRef.setValue(userDict) { error, _ in
            if let error = error {
                print("Veri güncellenemedi: \(error.localizedDescription)")
            } else {
                print("Veri başarıyla güncellendi.")
            }
        }
    }
    func fetchPostData(userId: String?, lastTimestamp: String?, firstTimestamp: String?, completion: @escaping (_ postModelData: [PostModel]?) -> Void) {
        let postRef = databaseRef?.child("Posts")
        postRef?.observeSingleEvent(of: .value, with: { snapshot in
            guard let allPostData = snapshot.value as? NSDictionary else { return }
            
            var posts = [PostModel]()
            
            posts = allPostData.allValues.compactMap { PostModel(dictionary: $0 as! NSDictionary
            )}
            
            completion(posts)
        })
    }
    
    func fetchUsersData(completion: @escaping (_ userModelData: [UserModel]?) -> Void) {
        let userRef = databaseRef?.child("Users")
        userRef?.observeSingleEvent(of: .value, with: { snapshot in
            guard let snapshotData = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            var userModels = [UserModel]()
            for (_, value) in snapshotData {
                if let userDict = value as? NSDictionary {
                    let userModel = UserModel(dictionary: userDict)
                    userModels.append(userModel)
                }
            }
            completion(userModels)
        }) { error in
            print("Veri çekilirken hata oluştu: \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    func fetchCurrentUserData(completion: @escaping (_ currentUser: UserModel?) -> Void) {
        guard let id = Auth.auth().currentUser?.uid else { return }
        let userRef = databaseRef?.child("Users").child(id)
        userRef?.observeSingleEvent(of: .value, with: { snapshot in
            guard let snapshotData = snapshot.value as? NSDictionary else {
                completion(nil)
                return
            }
            let userModel = UserModel(dictionary: snapshotData)
            completion(userModel)
        }) { error in
            print("Veri çekilirken hata oluştu: \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    func deletePost(postId : String) {
        guard !postId.isEmpty else {
            print("Post Id boş olamaz.")
            return
        }
        let ref = Database.database().reference().child("Posts").child(postId)
        ref.removeValue { error, _ in
            if let error = error {
                print("Hata oluştu: \(error.localizedDescription)")
            } else {
                print("Post başarıyla silindi.")
            }
        }
    }
    
    func uploadStoryToStorage(image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let storageRef = Storage.storage().reference().child("Users/\(UUID().uuidString).jpg")
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading story: \(error.localizedDescription)")
                completion(nil)
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    completion(url?.absoluteString)
                }
            }
        }
    }
    func updateUserStory(userModel: UserModel, storyUrl: String, completion: @escaping (UserModel?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        var userStory = userModel.userStory
        userStory.append(storyUrl)
        
        databaseRef?.child("Users").child(userId).child("userStory").setValue(userStory) { error, ref in
            if let error = error {
                print("Failed to update userStory: \(error.localizedDescription)")
                completion(nil)
            } else {
                var updatedUserModel = userModel
                updatedUserModel.userStory = userStory
                completion(updatedUserModel)
            }
        }
    }
    func createComment(postModel: PostModel, commentModel: CommentModel, completion: @escaping (CommentModel?) -> Void) {
        let commentRef = databaseRef?.child("Posts").child(postModel.postId).child("comments")
        
        commentRef?.observeSingleEvent(of: .value, with: { snapshot in
            let data = try! FirebaseEncoder().encode(commentModel)
            commentRef?.child(commentModel.commentId).setValue(data)
            completion(commentModel)
        })
    }
    
    func updateFollowersArray(userModel: UserModel, completion: @escaping (UserModel?) -> Void) {
        guard let userId = userModel.userId else {
            print("User not logged in")
            return
        }
        let userFollowersRef = databaseRef?.child("Users").child(userId).child("followersArray")
        userFollowersRef?.setValue(userModel.followersArray) { error, ref in
            if let error = error {
                print("Failed to update likeArray: \(error.localizedDescription)")
                completion(nil)
            } else {
                var updatedUserModel = userModel
                updatedUserModel.followersArray = userModel.followersArray
                completion(updatedUserModel)
            }
        }
    }
    
    func updateFollowingArray(userModel: UserModel, completion: @escaping (UserModel?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }
        let userFollowersRef = databaseRef?.child("Users").child(userId).child("followingArray")
        userFollowersRef?.setValue(userModel.followingArray) { error, ref in
            if let error = error {
                print("Failed to update likeArray: \(error.localizedDescription)")
                completion(nil)
            } else {
                var updatedUserModel = userModel
                updatedUserModel.followingArray = userModel.followingArray
                completion(updatedUserModel)
            }
        }
    }
    
    func updateSaveArray(postModel: PostModel, userId: String, completion: @escaping (PostModel?) -> Void) {
        var updatedPost = postModel
        if updatedPost.saveArray.contains(userId) {
            updatedPost.saveArray.removeAll { $0 == userId }
        } else {
            updatedPost.saveArray.append(userId)
        }
        
        let postRef = self.databaseRef?.child("Posts").child(postModel.postId)
        
        postRef?.updateChildValues(["saveArray": updatedPost.saveArray]) { error, _ in
            if let error = error {
                print("Kaydetme işlemi başarısız: \(error.localizedDescription)")
                completion(nil)
            } else {
                completion(updatedPost)
            }
        }
    }
}

