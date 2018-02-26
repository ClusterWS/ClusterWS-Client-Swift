//
//  Message.swift
//  CWSChat
//
//  Created by Roman Baitaliuk on 25/02/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import Foundation
import MessageKit

struct Message: MessageType {
    var messageId: String
    var sender: Sender
    var sentDate: Date
    var data: MessageData
    
    init(data: MessageData, sender: Sender, messageId: String, date: Date) {
        self.data = data
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
    }
    
    init(text: String, user: User) {
        self.init(data: .text(text), sender: user.getSender(), messageId: NSUUID().uuidString, date: Date())
    }
    
    init(text: String, sender: Sender, messageId: String, date: Date) {
        self.init(data: .text(text), sender: sender, messageId: messageId, date: date)
    }
}
