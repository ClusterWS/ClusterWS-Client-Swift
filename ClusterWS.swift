//
//  ClusterWS.swift
//  ClusterWS-Client-Swift
//
//  Created by Roman Baitaliuk on 3/10/17.
//

import Foundation
import Starscream

extension ClusterWS: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        self.delegate?.onConnected()
        print("Connected on Starscream")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("Disconnect on Starscream with error: \(String(describing: error?.localizedDescription.description))")
        self.delegate?.onDisconnected(error: error)
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print(text)
        if text == "#0" {
            self.send(event: "#1", data: nil, type: .ping)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
}

class ClusterWS {
    private var mOptions: Options!
    private var mWebSocket: WebSocket!
    var delegate: BasicListener?
    
    init(url: String, port: Int, autoReconnect: Bool? = nil, reconnectionInterval: Int? = nil, reconnectionAttempts: Int? = nil) {
        self.mOptions = Options(url: url, port: port, autoReconnect: autoReconnect, reconnectionInterval: reconnectionInterval, reconnectionAttempts: reconnectionAttempts)
        self.create()
    }
    
    private func create() {
        self.mWebSocket = WebSocket(url: URL(string: "ws://\(self.mOptions.getUrl()):\(self.mOptions.getPort())/")!)
        self.mWebSocket.delegate = self
    }
    
    public func connect() {
        self.mWebSocket.connect()
    }
    
    public func send(event: String, data: Any? = nil, type: MessageType? = nil) {
        if type == nil {
            self.mWebSocket.write(string: Message.messageEncode(event: event, data: data, type: .emit))
            print(Message.messageEncode(event: event, data: data, type: .emit))
        } else {
            self.mWebSocket.write(string: Message.messageEncode(event: event, data: data, type: type!))
            print(Message.messageEncode(event: event, data: data, type: type!))
        }
    }
}
