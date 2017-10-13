//
//  Message.swift
//  ClusterWS-Client-Swift
//
//  Created by Roman Baitaliuk on 3/10/17.
//

import Foundation

//MARK: Enumeration of message types

public enum MessageType: String {
    case publish = "publish"
    case emit = "emit"
    case system = "system"
    case ping = "ping"
}

open class Message {
    
    //MARK: Primary methods of ClusterWS
    
    static func messageEncode(event: String, data: Any? = nil, type: MessageType) -> String {
        var jsonDict: [String: Any] = [:]
        switch type {
        case .publish:
            jsonDict = ["#": ["p", event, data]]
            return self.JSONStringify(value: jsonDict, prettyPrinted: false)
        case .emit:
            jsonDict = ["#": ["e", event, data]]
            return self.JSONStringify(value: jsonDict, prettyPrinted: false)
        case .system:
            switch event {
                case "subscribe":
                    jsonDict = ["#": ["s", "s", data]]
                    return self.JSONStringify(value: jsonDict, prettyPrinted: false)
                case "unsubscribe":
                    jsonDict = ["#": ["s", "u", data]]
                    return self.JSONStringify(value: jsonDict, prettyPrinted: false)
                default:
                    return event
            }
        case .ping:
            return event
        }
    }
    
    static func messageDecode(socket: ClusterWS, message: String) {
        let jsonDict = self.convertToJSON(text: message)
        guard let jsonArray = jsonDict!["#"] as? [Any] else {
            return
        }
        switch String(describing: jsonArray[0]) {
        case "p":
            let channelName = String(describing: jsonArray[1])
            _ = socket.mChannels.filter { $0.mChannelName == channelName }.map { $0.onMessage(data: String(describing: jsonArray[2])) }
        case "e":
            socket.mEmitter.emit(event: String(describing: jsonArray[1]), data: jsonArray[2])
        case "s":
            switch String(describing: jsonArray[1]) {
                case "c":
                    guard let pingJSON = jsonArray[2] as? [String: Any] else {
                        fatalError("Unable to cast ping json to dictionary")
                    }
                    guard let pingInterval = pingJSON["ping"] as? Double else {
                        fatalError("Unable to cast ping object to numeric type")
                    }
                    socket.timer = Timer.scheduledTimer(withTimeInterval: pingInterval/1000, repeats: true, block: { (timer) in
                        if socket.mLost < 3 {
                            socket.mLost += 1
                        } else {
                            if socket.getState() != .closed {
                                socket.disconnect(closeCode: 4001, reason: "No pings")
                                timer.invalidate()
                            }
                        }
                    })
                default:
                    break
            }
        default:
            break
        }
    }
    
    //MARK: Helper methods
    
    static func convertToJSON(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    static func JSONStringify(value: Any, prettyPrinted:Bool = false) -> String {
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
        
        if JSONSerialization.isValidJSONObject(value) {
            do {
                let data = try JSONSerialization.data(withJSONObject: value, options: options)
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            } catch {
                print("error")
            }
        }
        
        return ""
    }
}
