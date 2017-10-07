//
//  ClusterWS.swift
//  ClusterWS-Client-Swift
//
//  Created by Roman Baitaliuk on 3/10/17.
//

import Foundation
import SwiftWebSocket

class ClusterWS {
    
    //MARK: Properties
    
    private let mOptions: Options!
    private var mWebSocket: WebSocket!
    public var delegate: BasicListener?
    open let mEmitter: Emitter!
    open var mChannels: [Channel]!
    
    //MARK: Initialization
    
    init(url: String, port: Int, autoReconnect: Bool? = nil, reconnectionInterval: Int? = nil, reconnectionAttempts: Int? = nil) {
        self.mOptions = Options(url: url, port: port, autoReconnect: autoReconnect, reconnectionInterval: reconnectionInterval, reconnectionAttempts: reconnectionAttempts)
        self.mEmitter = Emitter()
        self.mChannels = []
    }
    
    //MARK: Public methods
    
    public func connect() {
        guard let url = self.mOptions.mUrl, let port = self.mOptions.mPort else {
            fatalError("ClusterWS initialization is missing, try to initialize the class first")
        }
        self.mWebSocket = WebSocket(url: URL(string: "ws://\(url):\(port)/")!)
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
                if text == "#0" {
                    self.send(event: "#1", data: nil, type: .ping)
                } else {
                    Message.messageDecode(socket: self, message: text)
                }
            }
        }
    }
    
    public func on(event: String, fn: @escaping Listener) {
        self.mEmitter.on(event: event, fn: fn)
    }
    
    public func subscribe(channelName: String) -> Channel {
        var channel: Channel?
        _ = self.mChannels.filter { $0.mChannelName == channelName }.map { channel == $0 }
        if channel == nil {
            channel = Channel(channelName: channelName, socket: self)
            self.mChannels.append(channel!)
        }
        return channel!
    }
    
    public func disconnect() {
        self.mWebSocket.close()
    }
    
    public func getState() -> WebSocketReadyState {
        return self.mWebSocket.readyState
    }
    
    public func send(event: String, data: Any? = nil) {
        self.send(event: event, data: data, type: .emit)
    }
    
    //MARK: Open methods within the ClusterWS module
    
    open func send(event: String, data: Any? = nil, type: MessageType? = .emit) {
        self.mWebSocket.send(Message.messageEncode(event: event, data: data, type: type!))
    }
}
