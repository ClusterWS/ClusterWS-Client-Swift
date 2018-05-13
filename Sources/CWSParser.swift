//
//  CWSParser.swift
//  ClusterWS-Client-Swift
//
//  Created by Roman Baitaliuk on 3/10/17.
//

import Foundation

public enum MessageType: String {
    case publish
    case emit
    case system
}

public enum SystemEventType: String {
    case subscribe
    case unsubscribe
    static func type(by string: String) -> SystemEventType {
        switch string {
        case SystemEventType.subscribe.rawValue:
            return .subscribe
        default:
            return .unsubscribe
        }
    }
}

// MARK: - Properties & Initialization
open class CWSParser {
    
    private let mSocket: ClusterWS
    
    public init(socket: ClusterWS) {
        self.mSocket = socket
    }
}

// MARK: - Open methods

extension CWSParser {
    
    open func encode(event: String, data: Any? = nil, type: MessageType) -> String? {
        var jsonDict: [String: Any]
        switch type {
        case .publish:
            jsonDict = ["#": ["p", event, data]]
        case .emit:
            jsonDict = ["#": ["e", event, data]]
        case .system:
            switch SystemEventType.type(by: event) {
                case .subscribe:
                    jsonDict = ["#": ["s", "s", data]]
                case .unsubscribe:
                    jsonDict = ["#": ["s", "u", data]]
            }
        }
        return self.JSONStringify(value: jsonDict)
    }
    
    open func encode(message: String) -> Data? {
        return message.data(using: .utf8, allowLossyConversion: false)
    }
    
    open func handleMessage(with string: String) {
        guard let jsonDict = self.convertToJSON(text: string) else {
            self.mSocket.delegate?.onError(error: CWSError.JSONStringConversionError(string))
            return
        }
        guard let jsonArray = jsonDict["#"] as? [Any] else {
            self.mSocket.delegate?.onError(error: CWSError.hashArrayCastError(jsonDict))
            return
        }
        switch String(describing: jsonArray[0]) {
        case "p":
            self.handleP(with: jsonArray)
        case "e":
            self.handleE(with: jsonArray)
        case "s":
            self.handleS(with: jsonArray)
        default:
            break
        }
    }
}

// MARK: - Private methods

extension CWSParser {
    
    private func convertToJSON(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch let error {
                debugPrint("JSON string conversion error: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    private func JSONStringify(value: Any, prettyPrinted: Bool? = nil) -> String? {
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
    
    private func handleP(with data: [Any]) {
        let channelName = String(describing: data[1])
        let decodedMessage = self.mSocket.delegate?.decode(message: data[2]) ?? data[2]
        self.mSocket.getChannel(by: channelName)?.onMessage(data: decodedMessage)
    }
    
    private func handleE(with data: [Any]) {
        let event = String(describing: data[1])
        let decodedMessage = self.mSocket.delegate?.decode(message: data[2]) ?? data[2]
        self.mSocket.emit(event: event, data: decodedMessage)
    }
    
    private func handleS(with data: [Any]) {
        switch String(describing: data[1]) {
        case "c":
            let decodedMessage = self.mSocket.delegate?.decode(message: data[2]) ?? data[2]
            guard let pingJSON = decodedMessage as? [String: Any] else {
                self.mSocket.delegate?.onError(error: CWSError.pingJSONCastError(decodedMessage))
                return
            }
            guard let pingInterval = pingJSON["ping"] as? Double else {
                self.mSocket.delegate?.onError(error: CWSError.pingIntervalCastError(pingJSON))
                return
            }
            guard let binary = pingJSON["binary"] as? Bool else {
                self.mSocket.delegate?.onError(error: CWSError.binaryCastError(pingJSON))
                return
            }
            self.mSocket.setPingInterval(pingInterval * 2 + 100)
            self.mSocket.setBinary(to: binary)
            self.mSocket.delegate?.onConnect()
        default:
            break
        }
    }
}
