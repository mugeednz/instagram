//
//  Channel.swift
//  instagram
//
//  Created by Müge Deniz on 15.12.2024.
//

import Foundation
import FirebaseFirestore

struct Channel {
    var id: String?
    var name: String
    var otherUserId: [String]?
    
    init(name: String, otherUserId: [String]) {
        id = nil
        self.name = name
        self.otherUserId = otherUserId
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let name = data["name"] as? String else {
            return nil
        }
        
        guard let otherUserId = data["otherUserId"] as? [String] else {
            return nil
        }
        
        id = document.documentID
        self.name = name
        self.otherUserId = otherUserId
    }
}

extension Channel: DatabaseRepresentation {
    var representation: [String : Any] {
        var rep = ["name": name, "otherUserId": otherUserId ?? []] as [String: Any]
        if let id = id {
            rep["id"] = id
        }
        return rep
    }
}

extension Channel: Comparable {

  static func == (lhs: Channel, rhs: Channel) -> Bool {
    return lhs.id == rhs.id
  }

  static func < (lhs: Channel, rhs: Channel) -> Bool {
    return lhs.name < rhs.name
  }

}

protocol DatabaseRepresentation {
  var representation: [String: Any] { get }
}
