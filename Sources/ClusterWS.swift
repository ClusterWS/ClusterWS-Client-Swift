//
//  ClusterWS.swift
//  ClusterWS-Client-Swift
//
//  Created by Roman Baitaliuk on 3/10/17.
//

import Foundation
import SwiftWebSocket

class ClusterWS {
    private var mOptions: Options!
    private var mWebSocket: WebSocket!
    var delegate: BasicListener?
    
    init(url: String, port: Int, autoReconnect: Bool? = nil, reconnectionInterval: Int? = nil, reconnectionAttempts: Int? = nil) {
        self.mOptions = Options(url: url, port: port, autoReconnect: autoReconnect, reconnectionInterval: reconnectionInterval, reconnectionAttempts: reconnectionAttempts)
    }
    
    public func connect() {
        self.mWebSocket = WebSocket(url: URL(string: "ws://\(self.mOptions.getUrl()):\(self.mOptions.getPort())/")!)
        self.mWebSocket.event.open = {
            print("opened")
            self.delegate?.onConnect()
        }
        self.mWebSocket.event.close = { code, reason, clean in
            print("close with code: \(code), reason: \(reason)")
            self.delegate?.onDisconnect(code: code, reason: reason)
        }
        self.mWebSocket.event.error = { error in
            print("error \(error)")
            self.delegate?.onError(error: error)
        }
        self.mWebSocket.event.message = { message in
            if let text = message as? String {
                print(text)
                if text == "#0" {
                    self.send(event: "#1", data: nil, type: .ping)
                }
            }
        }
    }
    
    public func send(event: String, data: Any? = nil, type: MessageType? = nil) {
        if type == nil {
            self.mWebSocket.send(Message.messageEncode(event: event, data: data, type: .emit))
            print(Message.messageEncode(event: event, data: data, type: .emit))
        } else {
            self.mWebSocket.send(Message.messageEncode(event: event, data: data, type: type!))
            print(Message.messageEncode(event: event, data: data, type: type!))
        }
    }
}
