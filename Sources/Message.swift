//
//  Message.swift
//  ClusterWS-Client-Swift
//
//  Created by Roman Baitaliuk on 3/10/17.
//

import Foundation

enum MessageType: String {
    case publish = "publish"
    case emit = "emit"
    case system = "system"
    case ping = "ping"
}

class Message {
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
