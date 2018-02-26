//
//  ConversationViewController.swift
//  CWSChat
//
//  Created by Roman Baitaliuk on 29/01/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import UIKit
import ClusterWS_Client_Swift
import MessageKit

class ConversationViewController: MessagesViewController {
    
    public var user: User!
    public var webSocket: ClusterWS!
    public var currentUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // assigning delegates
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        
        // UI configs
        scrollsToBottomOnKeybordBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        self.title = self.user.name
        
        self.updateView()
    }
    
    public func updateView() {
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToBottom()
    }
    
    fileprivate func sendMessageToServer(messageText: String) {
        let object: [String: Any] = ["userID": self.user.id, "data": ["event": "message", "userName": self.currentSender().displayName, "userID": self.currentSender().id, "message": messageText]]
        self.webSocket.send(event: "sendToUser", data: object)
    }
}

// MARK: - MessagesLayoutDelegate
extension ConversationViewController: MessagesLayoutDelegate {
    func heightForLocation(message: MessageKit.MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 200.0
    }
}

// MARK: - MessagesDataSource
extension ConversationViewController: MessagesDataSource {
    func currentSender() -> Sender {
        return currentUser.getSender()
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageKit.MessageType {
        return self.user.messages[indexPath.section]
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return self.user.messages.count
    }
}

// MARK: - MessagesDisplayDelegate
extension ConversationViewController: MessagesDisplayDelegate {
    func textColor(for message: MessageKit.MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func messageStyle(for message: MessageKit.MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    func backgroundColor(for message: MessageKit.MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1) : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageKit.MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.set(avatar: self.user.getAvatar())
    }
}

// MARK: - MessageInputBarDelegate
extension ConversationViewController: MessageInputBarDelegate {
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // check if text is not empty
        guard !text.isEmpty else {
            return
        }
        
        // saving object to user array
        let currentUser = User(name: self.currentSender().displayName, id: self.currentSender().id)
        let messageObject = Message(text: text, user: currentUser)
        self.user.messages.append(messageObject)
        messagesCollectionView.insertSections([self.user.messages.count - 1])
        
        self.sendMessageToServer(messageText: text)

        // reseting input bar
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
    }
}

// MARL: - MessageProtocol
extension ConversationViewController: MessageProtocol {
    func didRecieveMessage() {
        self.updateView()
    }
}
