//
//  User.swift
//  CWSChat
//
//  Created by Roman Baitaliuk on 25/02/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import UIKit
import MessageKit

class User {
    var name: String
    var id: String
    var messages = [Message]()
    
    init(name: String, id: String) {
        self.name = name
        self.id = id
    }
    
    func getSender() -> Sender {
        return Sender(id: id, displayName: self.name)
    }
    
    func getAvatar() -> Avatar {
        let initials = self.name.components(separatedBy: " ").reduce("") { ($0 == "" ? "" : "\($0.first!)") + "\($1.first!)" }
        return Avatar(initials: initials)
    }
}
