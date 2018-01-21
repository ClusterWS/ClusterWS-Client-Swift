//
//  ClusterWS.swift
//  ClusterWS-Client-Swift
//
//  Created by Roman Baitaliuk on 3/10/17.
//

import Foundation

// MARK: Properties & Initialization
open class ClusterWS {
    public var delegate: ClusterWSDelegate?
    
    open let mEmitter: Emitter
    open let mPingHandler: PingHandler
    
    open var mChannels: [Channel] = []
    open var mUseBinary: Bool = false
    
    private let mUrl: String
    private var mWebSocket: WebSocket?
    
    private var mReconnectionHandler: ReconnectionHandler
    private let mMessageHandler: MessageHandler
    
    public init(url: String) {
        self.mUrl = url
        self.mEmitter = Emitter()
        self.mPingHandler = PingHandler()
        self.mReconnectionHandler = ReconnectionHandler()
        self.mMessageHandler = MessageHandler()
    }
}

// MARK: Public methods
extension ClusterWS {
    public func connect() {
        self.mReconnectionHandler.socket = self
        
        guard let url = URL(string: self.mUrl) else {
            self.delegate?.onError(error: ClusterWSErrors.invalidURL(self.mUrl))
            return
        }
        
        self.mWebSocket = WebSocket(url: url)
        
        if self.mUrl.range(of: "wss://") != nil {
            self.mWebSocket?.allowSelfSignedSSL = true
        }
        
        self.mWebSocket?.event.open = {
            self.mReconnectionHandler.onConnected()
        }
        
        self.mWebSocket?.event.close = { code, reason, clean in
            self.mPingHandler.reset()
            self.delegate?.onDisconnect(code: code, reason: reason)
            if self.mReconnectionHandler.mReconnectionTimer != nil {
                return
            }
            if self.mReconnectionHandler.mAutoReconnect && code != 1000 {
                self.mReconnectionHandler.reconnect()
            }
        }
        
        self.mWebSocket?.event.error = { error in
            self.delegate?.onError(error: error)
        }
        
        self.mWebSocket?.event.message = { message in
            var string: String = ""
            if let text = message as? String {
                string = text
            } else if let binary = message as? [UInt8] {
                string = String(bytes: binary, encoding: .utf8)!
            }
            if string == "#0" {
                self.mPingHandler.resetMissedPing()
                self.send(event: "#1", data: nil, type: .ping)
            } else {
                self.mMessageHandler.messageDecode(message: string, socket: self)
            }
        }
    }
    
    public func on(event: String, completion: @escaping CompletionHandler) {
        self.mEmitter.on(event: event, completion: completion)
    }
    
    public func subscribe(_ channelName: String) -> Channel {
        var channel = self.mChannels.filter { $0.mChannelName == channelName }.map { $0 }.first
        if channel == nil {
            channel = Channel(channelName: channelName, socket: self)
            self.mChannels.append(channel!)
        }
        return channel!
    }
    
    public func getChannels() -> [Channel] {
        return self.mChannels
    }
    
    public func getChannel(by name: String) -> Channel? {
        return self.mChannels.filter { $0.mChannelName == name }.first
    }
    
    public func disconnect(closeCode: Int? = nil, reason: String? = nil) {
        self.mWebSocket?.close(closeCode == nil ? 1000 : closeCode!, reason: reason == nil ? "" : reason!)
    }
    
    public func setReconnection(autoReconnect: Bool, reconnectionIntervalMin: Double, reconnectionIntervalMax: Double, reconnectionAttempts: Int) {
        self.mReconnectionHandler.socket = self
        self.mReconnectionHandler.mAutoReconnect = autoReconnect
        self.mReconnectionHandler.mReconnectionAttempts = reconnectionAttempts
        self.mReconnectionHandler.mReconnectionIntervalMin = reconnectionIntervalMin
        self.mReconnectionHandler.mReconnectionIntervalMax = reconnectionIntervalMax
    }
    
    public func getState() -> WebSocketReadyState {
        guard let state = self.mWebSocket?.readyState else {
            return .closed
        }
        return state
    }
    
    public func send(event: String, data: Any? = nil) {
        self.send(event: event, data: data, type: .emit)
    }
}

// MARK: Open methods
extension ClusterWS {
    open func send(event: String, data: Any? = nil, type: MessageType) {
        if self.mUseBinary {
            guard let encodedData = self.mMessageHandler.messageEncode(event: event,
                                                                      data: data,
                                                                      type: type)?.data(using: .utf8) else {
                                                                        self.delegate?.onError(error: ClusterWSErrors.JSONStringifyError(data))
                                                                        return
            }
            self.mWebSocket?.send(encodedData)
        } else {
            guard let anyData = self.mMessageHandler.messageEncode(event: event, data: data, type: type) else {
                self.delegate?.onError(error: ClusterWSErrors.JSONStringifyError(data))
                return
            }
            self.mWebSocket?.send(anyData)
        }
    }
}
