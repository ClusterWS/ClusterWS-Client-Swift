//
//  InboxTableViewController.swift
//  CWSChat
//
//  Created by Roman Baitaliuk on 25/02/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import UIKit
import ClusterWS_Client_Swift

protocol MessageProtocol: class {
    func didRecieveMessage()
}

class InboxTableViewController: UITableViewController {
    fileprivate var webSocket: ClusterWS?
    fileprivate var users = [User]()
    fileprivate var currentUser: User!
    weak var delegate: MessageProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Connected Users"
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        // socket configs
        self.webSocket = ClusterWS(url: "ws://t-w-a.herokuapp.com")
        self.webSocket?.delegate = self
        self.webSocket?.connect()
        
        // if user have been already lunched the app
        guard let currentUser = UserDefaults.standard.value(forKey: "user") as? [String: String] else {
            return
        }
        let currentUserId = currentUser["userId"]!
        let currentUserName = currentUser["userName"]!
        
        self.currentUser = User(name: currentUserName, id: currentUserId)
        
        self.handlingEvents(for: self.currentUser)
    }
    
    fileprivate func handlingEvents(for user: User) {
        self.webSocket?.send(event: "setID", data: user.id)
        
        // current user subscription
        
        _ = self.webSocket?.subscribe(user.id).watch(completion: { (data) in
            print("Current user data: \(data)")
            guard let jsonDict = data as? [String: Any] else {
                return
            }
            guard let event = jsonDict["event"] as? String else {
                return
            }
            if event == "connected" {
                guard let userId = jsonDict["connectedUserID"] as? String,
                    let userName = jsonDict["connectedUserName"] as? String else {
                    return
                }
                // save new connected user
                let newUser = User(name: userName, id: userId)
                self.users.append(newUser)
                
                self.tableView.reloadData()
            } else if event == "message" {
                guard let userId = jsonDict["userID"] as? String,
                    let messageText = jsonDict["message"] as? String else {
                        return
                }
                let newUser = self.users.filter { $0.id == userId }.first
                let message = Message(text: messageText, user: newUser!)
                newUser?.messages.append(message)
                
                // update view here
                self.delegate?.didRecieveMessage()
            }
        })
        
        // global subscription
        
        // sending data in JSON string
        let object: [String: Any] = ["userID": user.id, "userName": user.name, "event": "connect"]
        guard let jsonString = self.JSONStringify(value: object) else {
            return
        }
        
        _ = self.webSocket?.subscribe("global").publish(data: jsonString).watch(completion: { (data) in
            print("Global data: \(data)")
            
            // converting json to dictionary
            var jsonDict: [String: Any]!
            if let dictionary = data as? [String: Any] {
                jsonDict = dictionary
            } else if let jsonString = data as? String, let convertedDict = self.convertToJSON(text: jsonString) {
                jsonDict = convertedDict
            }
            
            guard let event = jsonDict["event"] as? String, let userId = jsonDict["userID"] as? String else {
                return
            }
            
            if event == "connect" {
                if userId == user.id {
                    return
                } else {
                    // save new connected user
                    guard let newUserName = jsonDict["userName"] as? String else {
                        return
                    }
                    let newUser = User(name: newUserName, id: userId)
                    self.users.append(newUser)
                    
                    let object: [String: Any] = ["userID": userId, "data": ["event": "connected", "connectedUserName": user.name, "connectedUserID": user.id]]
                    self.webSocket?.send(event: "sendToUser", data: object)
                }
            } else if event == "disconnect" {
                // deleting user if that have been disconnected
                let newUsers = self.users.filter { $0.id != userId }
                self.users = newUsers
            }
            self.tableView.reloadData()
        })
    }
    
    fileprivate func showAlert() {
        // create the alert controller.
        let alert = UIAlertController(title: "Your Name", message: nil, preferredStyle: .alert)
        
        // add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Enter your name"
        }
        
        // grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if let currentUserName = textField?.text {
                // saving current user to default
                let currentUserId = self.createUserId()
                
                let currentUser = User(name: currentUserName, id: currentUserId)
                self.currentUser = currentUser
                
                let userObject: [String: String] = ["userId": currentUserId, "userName": currentUserName]
                UserDefaults.standard.set(userObject, forKey: "user")
                
                self.handlingEvents(for: currentUser)
            } else {
                // handle empty state
            }
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - TableViewDataSource
extension InboxTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? InboxTableViewCell else {
            fatalError("Couldn't cast cell")
        }
        cell.userNameLabel.text = self.users[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversationViewController = ConversationViewController()
        self.delegate = conversationViewController
        conversationViewController.user = self.users[indexPath.row]
        conversationViewController.webSocket = self.webSocket
        conversationViewController.currentUser = self.currentUser
        self.navigationController?.pushViewController(conversationViewController, animated: true)
    }
}

// MARK: - CWSDelegate
extension InboxTableViewController: CWSDelegate {
    func onConnect() {
        if self.currentUser == nil {
            self.showAlert()
        }
    }
    
    func onDisconnect(code: Int?, reason: String?) {
        
    }
    
    func onError(error: Error) {
        
    }
}

// MARK: - Helpers
extension InboxTableViewController {
    fileprivate func JSONStringify(value: Any, prettyPrinted: Bool? = nil) -> String? {
        let options = prettyPrinted ?? false ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
        
        if JSONSerialization.isValidJSONObject(value) {
            do {
                let data = try JSONSerialization.data(withJSONObject: value, options: options)
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            } catch let error {
                debugPrint("JSON stringify error: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    fileprivate func convertToJSON(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch let error {
                debugPrint("JSON string conversion error: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    /**
         Creating unique user id
     */
    fileprivate func createUserId() -> String {
        let uuid = NSUUID().uuidString
        if let range = uuid.range(of: "-") {
            let firstPart = uuid[(uuid.startIndex)..<range.lowerBound]
            return String(firstPart)
        }
        return ""
    }
}
