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
        self.clusterWSDelegate?.onConnected()
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
}

class ClusterWS {
    private var mOptions: Options!
    private var mWebSocket: WebSocket!
    fileprivate var clusterWSDelegate: BasicListener?
    
    init(url: String, port: Int, autoReconnect: Bool, reconnectionInterval: Int, reconnectionAttempts: Int) {
        self.mOptions = Options(url: url, port: port, autoReconnect: autoReconnect, reconnectionInterval: reconnectionInterval, reconnectionAttempts: reconnectionAttempts)
        self.create()
    }
    
    private func create() {
        self.mWebSocket = WebSocket(url: URL(string: "ws://\(self.mOptions.getUrl()):\(self.mOptions.getPort())")!)
        self.mWebSocket.delegate = self
        
    }
    
    public func connect() {
        self.mWebSocket.connect()
    }
}
