//
//  PostModel.swift
//  instagram
//
//  Created by Müge Deniz on 11.11.2024.
//

import Foundation

class PostModel: Codable {
    
    var commentDict: [CommentModel]
    var locationInfo: PlaceModel!
    var likeArray: [String]
    var saveArray: [String]
    var postPhoto: [String]
    var isLike = false
    var isSave = false
    var postId: String
    var userId: String
    var timestamp: String?
    var newPostPhotoInfo: String?
    
    init(dictionary: [String: Any]) {
            self.commentDict = []
            self.likeArray = []
            self.saveArray = []
            self.postPhoto = []
            self.postId = ""
            self.userId = ""
        }

    enum CodingKeys: String, CodingKey {
        case comments
        case likeArray
        case saveArray
        case postPhoto
        case postId
        case userId
        case timestamp
        case isLike
        case isSave
        case photoInfo
        case locationInfo
    }
    
    var asDictionary: [String: Any] {
        let mirror = Mirror(reflecting: self)
        let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label: String?, value: Any) -> (String, Any)? in
            guard let label = label else { return nil }
            return (label, value)
        }).compactMap { $0 })
        return dict
    }
    
    init(commentDict: [CommentModel], like: [String], postP: [String],  isLiked: Bool, isSaved: Bool, postId: String, userId: String, timestamp: String, saveArray: [String], newPostPhotoInfo: String, locationInfo: PlaceModel) {
        
        self.saveArray  = saveArray
        self.commentDict = commentDict
        self.likeArray = like
        self.postPhoto = postP
        self.isLike = isLiked
        self.isSave = isSaved
        self.postId = postId
        self.userId = userId
        self.timestamp = timestamp
        self.newPostPhotoInfo = newPostPhotoInfo
        self.locationInfo = locationInfo
    }
    
    convenience init(dictionary: NSDictionary) {
        
        var dictioanrySaveArray = [String]()
        if let saveArray = dictionary["saveArray"] as? [String] {
            dictioanrySaveArray = saveArray
        } else {
            dictioanrySaveArray = []
        }
        
        var dictionaryComment = [CommentModel]()
        
        if let commentDict = dictionary["comments"] as? NSDictionary {
            dictionaryComment = commentDict.compactMap{ CommentModel(dictionary: $0.value as! NSDictionary) }
        } else {
            dictionaryComment = []
        }
        
        var dictPlaceModel: PlaceModel!
        
        if let locationInfo = dictionary["locationInfo"] as? NSDictionary {
            dictPlaceModel = PlaceModel(dictionary: locationInfo)
        } else {
            dictPlaceModel = PlaceModel.init(locationModel: LocationModel.init(latitude: 0.0, longitude: 0.0), placeName: "", placePhoto: "")
        }
        
        var dictionaryPostPhotoArray = [String]()
        if let postPhoto = dictionary["postPhoto"] as? [String] {
            dictionaryPostPhotoArray = postPhoto
        } else {
            dictionaryPostPhotoArray = []
        }
        
        var dictionaryLikeArray = [String]()
        if let likeArray = dictionary["likeArray"] as? [String] {
            dictionaryLikeArray = likeArray
        } else {
            dictionaryLikeArray = []
        }
        
        var dictionaryUserId = String()
        if let userId = dictionary["userId"] as? String {
            dictionaryUserId = userId
        } else {
            dictionaryUserId = ""
        }

        
        var dictionaryNewPostPhotoInfo = String()
        if let newPostPhotoInfo = dictionary["postInfo"] as? String {
            dictionaryNewPostPhotoInfo = newPostPhotoInfo
        } else {
            dictionaryNewPostPhotoInfo = ""
        }
        
        var dictionaryPostId = String()
        if let postId = dictionary["postId"] as? String {
            dictionaryPostId = postId
        } else {
            dictionaryPostId = ""
        }
        
        var dictionaryTimestamp = String()
        if let timestamp = dictionary["timestamp"] as? String {
            dictionaryTimestamp = timestamp
        } else {
            dictionaryTimestamp = ""
        }
        
        var dictionaryIsLike: Bool
        if let isLike = dictionary["isLike"] as? Bool {
            dictionaryIsLike = isLike
        } else {
            dictionaryIsLike = false
            
        }
        
        var dictionaryIsSave: Bool
        if let isSave = dictionary["isSave"] as? Bool {
            dictionaryIsSave = isSave
        } else {
            dictionaryIsSave = false
            
        }
        
        
        self.init(commentDict: dictionaryComment, like: dictionaryLikeArray, postP: dictionaryPostPhotoArray, isLiked: dictionaryIsLike, isSaved: dictionaryIsSave, postId: dictionaryPostId, userId: dictionaryUserId, timestamp: dictionaryTimestamp, saveArray: dictioanrySaveArray, newPostPhotoInfo: dictionaryNewPostPhotoInfo, locationInfo: dictPlaceModel)
    }
    

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(commentDict, forKey: .comments)
        try container.encode(locationInfo, forKey: .locationInfo)
        try container.encode(likeArray, forKey: .likeArray)
        try container.encode(saveArray, forKey: .saveArray)
        try container.encode(postPhoto, forKey: .postPhoto)
        try container.encode(isLike, forKey: .isLike)
        try container.encode(isSave, forKey: .isSave)
        try container.encode(postId, forKey: .postId)
        try container.encode(userId, forKey: .userId)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(newPostPhotoInfo, forKey: .photoInfo)


        
    }
    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        commentDict     = try container.decode([CommentModel].self, forKey: .comments)
        likeArray       = try container.decode([String].self, forKey: .likeArray)
        saveArray       = try container.decode([String].self, forKey: .saveArray)
        postPhoto       = try container.decode([String].self, forKey: .postPhoto)
        postId          = try container.decode(String.self, forKey: .postId)
        userId          = try container.decode(String.self, forKey: .userId)
        timestamp       = try container.decode(String.self, forKey: .timestamp)
        isSave          = try container.decode(Bool.self, forKey: .isSave)
        isLike          = try container.decode(Bool.self, forKey: .isLike)
        newPostPhotoInfo     = try container.decode(String.self, forKey: .photoInfo)
        locationInfo     = try container.decode(PlaceModel.self, forKey: .locationInfo)
        
        
    }
}
class CommentModel: Codable {
    
    var commentText: String
    var commentLikeArray: [String]
    var userId: String
    var commentId: String
    
    
    enum CodingKeys: String, CodingKey {
        case commentText
        case commentLikeArray
        case userId
        case commentId
    }
    
    var asDictionary: [String: Any] {
        let mirror = Mirror(reflecting: self)
        let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label: String?, value: Any) -> (String, Any)? in
            guard let label = label else { return nil }
            return (label, value)
        }).compactMap { $0 })
        return dict
    }
    
    init(commentText: String, commentLikeArray: [String], userId: String, commentId: String) {
        self.commentText = commentText
        self.commentLikeArray = commentLikeArray
        self.userId = userId
        self.commentId = commentId
    }
    
    convenience init(dictionary: NSDictionary) {
        
        var dictioanryCommentLikeArray = [String]()
        if let commentLikeArray = dictionary["commentLikeArray"] as? [String] {
            dictioanryCommentLikeArray = commentLikeArray
        } else {
            dictioanryCommentLikeArray = []
        }
        
        var dictionaryCommentText = String()
        if let commentText = dictionary["commentText"] as? String {
            dictionaryCommentText = commentText
        } else {
            dictionaryCommentText = ""
        }
        
        
        var dictionaryUserId = String()
        if let userId = dictionary["userId"] as? String {
            dictionaryUserId = userId
        } else {
            dictionaryUserId = ""
        }
        
        var dictionaryCommentId = String()
        if let commentId = dictionary["commentId"] as? String {
            dictionaryCommentId = commentId
        } else {
            dictionaryCommentId = ""
        }
        
        
        
        self.init(commentText: dictionaryCommentText, commentLikeArray: dictioanryCommentLikeArray, userId: dictionaryUserId, commentId: dictionaryCommentId)
    }
    
//    public func encode(with aCoder: NSCoder) {
//
//        aCoder.encode(commentText, forKey: "commentText")
//        aCoder.encode(commentLikeArray, forKey: "commentLikeArray")
//        aCoder.encode(userId, forKey: "userId")
//        aCoder.encode(commentId, forKey: "commentId")
//    }
//
//    required init(coder aDecoder: NSCoder) {
//
//
//        commentLikeArray = ((aDecoder.decodeObject(forKey: "commentLikeArray") as? [String])!)
//        commentText = ((aDecoder.decodeObject(forKey: "commentText") as? String)!)
//        userId = ((aDecoder.decodeObject(forKey: "userId") as? String)!)
//        commentId = ((aDecoder.decodeObject(forKey: "commentId") as? String)!)
//
//    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(commentText, forKey: .commentText)
        try container.encode(commentLikeArray, forKey: .commentLikeArray)
        try container.encode(userId, forKey: .userId)
        try container.encode(commentId, forKey: .commentId)
        
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        commentText = try container.decode(String.self, forKey: .commentText)
        commentLikeArray = try container.decode([String].self, forKey: .commentLikeArray)
        userId = try container.decode(String.self, forKey: .userId)
        commentId = try container.decode(String.self, forKey: .commentId)
        
        
    }
}


class PlaceModel: Codable {
    
    var locationModel: LocationModel!
    var placeName: String?
    var placePhoto: String?
    
    func toDictionary() -> [String: Any] {
           return [
               "locationModel": locationModel.toDictionary(),
               "placeName": placeName ?? "",
               "placePhoto": placePhoto ?? ""
           ]
       }
    
    enum CodingKeys: String, CodingKey {
        case locationModel
        case placeName
        case placePhoto
        
    }
    
    var asDictionary: [String: Any] {
        let mirror = Mirror(reflecting: self)
        let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label: String?, value: Any) -> (String, Any)? in
            guard let label = label else { return nil }
            return (label, value)
        }).compactMap { $0 })
        return dict
    }
    
    init(locationModel: LocationModel, placeName: String, placePhoto: String) {
        
        self.locationModel  = locationModel
        self.placeName = placeName
        self.placePhoto = placePhoto
        
    }
    
    convenience init(dictionary: NSDictionary) {
        
        var dictPlaceName = String()
        if let placeName = dictionary["placeName"] as? String {
            dictPlaceName = placeName
        } else {
            dictPlaceName = ""
        }
        
        var dictPlacePhoto = String()
        if let placePhoto = dictionary["placePhoto"] as? String {
            dictPlacePhoto = placePhoto
        } else {
            dictPlacePhoto = ""
        }
        
        var dictLocationModel: LocationModel!
        
        if let locationModel = dictionary["locationModel"] as? NSDictionary {
            dictLocationModel = LocationModel(dictionary: locationModel)
        } else {
            dictLocationModel = LocationModel.init(latitude: 0.0, longitude: 0.0)
        }
        
        
        
        self.init(locationModel: dictLocationModel, placeName: dictPlaceName, placePhoto: dictPlacePhoto)
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(locationModel, forKey: .locationModel)
        try container.encode(placePhoto, forKey: .placePhoto)
        try container.encode(placeName, forKey: .placeName)
        
        
        
    }
    required init(from decoder: Decoder) throws {
        let container  = try decoder.container(keyedBy: CodingKeys.self)
        locationModel = try container.decode(LocationModel.self, forKey: .locationModel)
        placePhoto = try container.decode(String.self, forKey: .placePhoto)
        placeName = try container.decode(String.self, forKey: .placeName)
        
        
        
    }
}


class LocationModel: Codable {

    var locationLatitude: Double
    var locationLongitude: Double
    
    func toDictionary() -> [String: Any] {
          return [
              "latitude": locationLatitude,
              "longitude": locationLongitude
          ]
      }
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
       
    }
    
    var asDictionary: [String: Any] {
        let mirror = Mirror(reflecting: self)
        let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label: String?, value: Any) -> (String, Any)? in
            guard let label = label else { return nil }
            return (label, value)
        }).compactMap { $0 })
        return dict
    }
    
    init(latitude: Double, longitude: Double) {
        self.locationLatitude = latitude
        self.locationLongitude = longitude
       
    }
    
    convenience init(dictionary: NSDictionary) {
        
        var dictLocationLatitude = Double()
        if let locationLatitude = dictionary["latitude"] as? Double {
            dictLocationLatitude = locationLatitude
        } else {
            dictLocationLatitude = 0.0
        }
     
        var dictLocationLongitude = Double()
        if let locationLongitude = dictionary["longitude"] as? Double {
            dictLocationLongitude = locationLongitude
        } else {
            dictLocationLongitude = 0.0
        }
        
       
        
        
        self.init(latitude: dictLocationLatitude, longitude: dictLocationLongitude)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(locationLatitude, forKey: .latitude)
        try container.encode(locationLongitude, forKey: .longitude)
        
        
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        locationLatitude = try container.decode(Double.self, forKey: .latitude)
        locationLongitude = try container.decode(Double.self, forKey: .longitude)

    }
}
