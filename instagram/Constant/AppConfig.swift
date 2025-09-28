//
//  AppConfig.swift
//  instagram
//
//  Created by Müge Deniz on 3.11.2024.
//

import Foundation

class UserModel: Codable {
    
    var bioInfo: String?
    var userName: String?
    var userSurname: String?
    var userNickName: String?
    var profilePhoto: String?
    var followersArray: [String]
    var followingArray: [String]
    var userId: String?
    var userStory: [String]
    var playerID: String?
    
    var asDictionary: [String: Any] {
        let mirror = Mirror(reflecting: self)
        let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label: String?, value: Any) -> (String, Any)? in
            guard let label = label else { return nil }
            return (label, value)
        }).compactMap { $0 })
        return dict
    }
    
    
    required init(bioInfo: String, userName: String,userSurname: String, userNickName: String, profilePhoto: String, followersArray: [String], followingArray: [String], userId: String, userStory: [String], playerID: String) {
        
        self.bioInfo = bioInfo
        self.userName = userName
        self.userSurname = userSurname
        self.userNickName = userNickName
        self.profilePhoto = profilePhoto
        self.followersArray = followersArray
        self.followingArray = followingArray
        self.userId = userId
        self.userStory = userStory
        self.playerID = playerID
    }
    
    convenience init(dictionary: NSDictionary) {
        
        var dictionaryBioInfo = ""
        if let bioInfo = dictionary["bioInfo"] as? String {
            dictionaryBioInfo = bioInfo
        }
        
        var dictionaryPlayerID = ""
        if let playerID = dictionary["playerID"] as? String {
            dictionaryPlayerID = playerID
        }
        
        var dictionaryUserName = ""
        if let userName = dictionary["userName"] as? String {
            dictionaryUserName = userName
        }
        
        var dictionaryUserNickName = ""
        if let userNickName = dictionary["userNickName"] as? String {
            dictionaryUserNickName = userNickName
        }
        
        var dictionaryUserSurname = ""
        if let userSurname = dictionary["userSurname"] as? String {
            dictionaryUserSurname = userSurname
        }
        
        var dictionaryProfilePhoto = ""
        if let profilePhoto = dictionary["profilePhoto"] as? String {
            dictionaryProfilePhoto = profilePhoto
        }
        
        var dictFollowerArray = [String]()
        if let followerArray = dictionary["followersArray"] as? [String] {
            dictFollowerArray = followerArray
        }
        
        var dictFollowingArray = [String]()
        if let followingArray = dictionary["followingArray"] as? [String] {
            dictFollowingArray = followingArray
        }
        
        var dictUserId = ""
        if let userId = dictionary["userId"] as? String {
            dictUserId = userId
        }
        
        var dictionaryUserStory = [String]()
        if let userStory = dictionary["userStory"] as? [String] {
            dictionaryUserStory = userStory
        }
        
        self.init(bioInfo: dictionaryBioInfo, userName: dictionaryUserName, userSurname: dictionaryUserSurname, userNickName: dictionaryUserNickName, profilePhoto: dictionaryProfilePhoto, followersArray: dictFollowerArray, followingArray: dictFollowingArray, userId: dictUserId, userStory: dictionaryUserStory, playerID: dictionaryPlayerID)
    }
    
    
    required init(coder aDecoder: NSCoder) {
        userName = (aDecoder.decodeObject(forKey: "userName") as! String)
        userSurname = (aDecoder.decodeObject(forKey: "userSurname") as! String)
        userNickName = (aDecoder.decodeObject(forKey: "userNickName") as! String)
        bioInfo = (aDecoder.decodeObject(forKey: "bioInfo") as! String)
        profilePhoto = aDecoder.decodeObject(forKey: "profilePhoto") as? String
        playerID = aDecoder.decodeObject(forKey: "playerID") as? String
        userId = aDecoder.decodeObject(forKey: "userId") as? String
        userStory = (aDecoder.decodeObject(forKey: "userStory") as? [String])!
        followersArray = (aDecoder.decodeObject(forKey: "followersArray") as? [String])!
        followingArray = (aDecoder.decodeObject(forKey: "followingArray") as? [String])!
        
        
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(userName, forKey: "userName")
        aCoder.encode(userSurname, forKey: "userSurname")
        aCoder.encode(userNickName, forKey: "userNickName")
        aCoder.encode(profilePhoto, forKey: "profilePhoto")
        aCoder.encode(bioInfo, forKey: "bioInfo")
        aCoder.encode(profilePhoto, forKey: "profilePhoto")
        aCoder.encode(followingArray, forKey: "followingArray")
        aCoder.encode(followersArray, forKey: "followersArray")
        aCoder.encode(userId, forKey: "userId")
        aCoder.encode(userStory, forKey: "userStory")
        aCoder.encode(playerID, forKey: "playerID")
    }
}

struct UserPostModel: Identifiable {
    var id: ObjectIdentifier
    var userModel: UserModel?
    var postModel: PostModel?
}
