//
//  MessageHandler.swift
//  ClusterWS-Client-Swift
//
//  Created by Roman Baitaliuk on 3/10/17.
//

import Foundation

public enum MessageType: String {
    case publish
    case emit
    case system
    case ping
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

// MARK: Properties & Initialization
open class MessageHandler {
    private let mConverter: JSONConverter
    
    public init() {
        self.mConverter = JSONConverter()
    }
}

//MARK: Open methods
extension MessageHandler {
    open func messageEncode(event: String, data: Any? = nil, type: MessageType) -> String? {
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
        case .ping:
            return event
        }
        guard let jsonString = self.mConverter.JSONStringify(value: jsonDict) else {
            return nil
        }
        return jsonString
    }
    
    open func messageDecode(message: String, socket: ClusterWS) {
        guard let jsonDict = self.mConverter.convertToJSON(text: message) else {
            socket.delegate?.onError(error: ClusterWSErrors.JSONStringConversionError(message))
            return
        }
        guard let jsonArray = jsonDict["#"] as? [Any] else {
            socket.delegate?.onError(error: ClusterWSErrors.hashArrayCastError(jsonDict))
            return
        }
        switch String(describing: jsonArray[0]) {
        case "p":
            let channelName = String(describing: jsonArray[1])
            socket.mChannels.filter { $0.mChannelName == channelName }.forEach { $0.onMessage(data: String(describing: jsonArray[2])) }
        case "e":
            socket.mEmitter.emit(event: String(describing: jsonArray[1]), data: jsonArray[2])
        case "s":
            switch String(describing: jsonArray[1]) {
                case "c":
                    guard let pingJSON = jsonArray[2] as? [String: Any] else {
                        socket.delegate?.onError(error: ClusterWSErrors.pingJSONCastError(jsonArray[2]))
                        return
                    }
                    guard let pingInterval = pingJSON["ping"] as? Double else {
                        socket.delegate?.onError(error: ClusterWSErrors.pingIntervalCastError(pingJSON))
                        return
                    }
                    guard let useBinary = pingJSON["binary"] as? Bool else {
                        socket.delegate?.onError(error: ClusterWSErrors.binaryCastError(pingJSON))
                        return
                    }
                    socket.mPingHandler.runPingTimer(interval: pingInterval, socket: socket)
                    socket.mUseBinary = useBinary
                    socket.delegate?.onConnect()
                default:
                    break
            }
        default:
            break
        }
    }
}
