//
//  ChatModel.swift
//  instagram
//
//  Created by Müge Deniz on 11.12.2024.
//

import Foundation
import MessageKit
import AVKit
import CoreLocation
import FirebaseAuth
import FirebaseFirestore

struct MessageStruct: MessageType {
    var image: ImageMediaItem?
    var audio: AudioMediaItem?
    var location: CoordinateItem?
    var contact: ShareContactItem?
    var downloadURL: URL? = nil
    var downloadLocation: GeoPoint? = nil
    var downloadContact: String? = nil
    
    let id: String?
    var sender: MessageKit.SenderType
    var messageId: String {
        return id ?? UUID().uuidString
    }
    var content: String?
    var sentDate: Date
    var kind: MessageKind {
        if let image = image {
            return .photo(image)
        } else if let audio = audio  {
            return .audio(audio)
        } else if let location = location {
            return .location(location)
        } else if let contact = contact {
            return .contact(contact)
        } else {
            return .text(content ?? "")
        }
    }
    
    init(user: User, content: String) {
        sender = Sender(senderId: user.uid, displayName: "")
        self.content = content
        sentDate = Date()
        id = nil
    }
    
    init(user: User, image: UIImage) {
        sender = Sender(senderId: user.uid, displayName: "")
        self.image = ImageMediaItem(image: image)
        sentDate = Date()
        content = ""
        id = nil
    }
    
    init(user: User, url: URL) {
        sender = Sender(senderId: user.uid, displayName: "")
        self.audio = AudioMediaItem(url: url)
        sentDate = Date()
        content = ""
        id = nil
    }
    
    init(user: User, location: CLLocation) {
        sender = Sender(senderId: user.uid, displayName: "")
        self.location = CoordinateItem(location: location)
        sentDate = Date()
        content = ""
        id = nil
    }
    
    init(user: User, contact: String) {
        sender = Sender(senderId: user.uid, displayName: "")
        self.contact = ShareContactItem(displayName: contact, initials: "")
        sentDate = Date()
        content = ""
        id = nil
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let sentDate = data["created"] as? Timestamp else {
            return nil
        }
        guard let senderID = data["senderID"] as? String else {
            return nil
        }
        guard let senderName = data["senderName"] as? String else {
            return nil
        }
        
        id = document.documentID
        
        self.sentDate = sentDate.dateValue()
        sender = Sender(senderId: senderID, displayName: senderName)
        
        if let content = data["content"] as? String {
            self.content = content
            downloadURL = nil
        } else if let urlStr = data["url"] as? String, let url = URL(string: urlStr) {
            content = ""
            downloadURL = url
        } else if let location = data["location"] as? GeoPoint {
            downloadURL = nil
            content = ""
            downloadLocation = location
        } else if let contact = data["contact"] as? String {
            downloadURL = nil
            content = ""
            downloadContact = contact
        } else {
            return nil
        }
        
    }
}

extension MessageStruct: DatabaseRepresentation {
    
    var representation: [String : Any] {
        var rep: [String : Any] = [
            "created": sentDate,
            "senderID": sender.senderId,
            "senderName": sender.displayName
        ]
        
        if let url = downloadURL {
            rep["url"] = url.absoluteString
        } else if let userLocation = downloadLocation {
            rep["location"] = userLocation
        } else if let userContact = downloadContact {
            rep["contact"] = userContact
        } else {
            rep["content"] = content
        }
        
        return rep
    }
    
}

extension MessageStruct: Comparable {
    
    static func == (lhs: MessageStruct, rhs: MessageStruct) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: MessageStruct, rhs: MessageStruct) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
    
}

struct ImageMediaItem: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(image: UIImage){
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
    
}

struct AudioMediaItem: AudioItem {
    var url: URL
    var size: CGSize
    var duration: Float
    
    init(url: URL){
        self.url = url
        self.size = CGSize(width: 160, height: 35)
        let avAsset = AVURLAsset(url: url)
        self.duration = Float(CMTimeGetSeconds(avAsset.duration))
    }
    
}

struct CoordinateItem: LocationItem {
    var location: CLLocation
    var size: CGSize
    
    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }
}

struct ShareContactItem: ContactItem {
    var displayName: String
    var initials: String
    var phoneNumbers: [String]
    var emails: [String]
    
    init(displayName: String, initials: String, phoneNumbers: [String] = [], emails: [String] = []) {
        self.displayName = displayName
        self.initials = initials
        self.phoneNumbers = phoneNumbers
        self.emails = emails
    }
    
}
