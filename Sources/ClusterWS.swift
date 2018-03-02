//
//  ClusterWS.swift
//  ClusterWS-Client-Swift
//
//  Created by Roman Baitaliuk on 3/10/17.
//

import Foundation

// MARK: Properties & Initialization
open class ClusterWS: NSObject {
    public var delegate: CWSDelegate?
    private let mEmitter: CWSEmitter
    private let mPingHandler: CWSPing
    private var mChannels: [CWSChannel] = []
    private var mUseBinary: Bool = false
    private let mUrl: String
    private var mWebSocket: WebSocket?
    private lazy var mReconnection = CWSReconnection(socket: self)
    private lazy var mParser = CWSParser(socket: self)
    
    public init(url: String) {
        self.mUrl = url
        self.mEmitter = CWSEmitter()
        self.mPingHandler = CWSPing()
    }
}

// MARK: Public methods
extension ClusterWS {
    public func connect() {
        guard let url = URL(string: self.mUrl) else {
            self.delegate?.onError(error: CWSErrors.invalidURL(self.mUrl))
            return
        }
        
        self.mWebSocket = WebSocket(url: url)
        
        if self.mUrl.range(of: "wss://") != nil {
            self.mWebSocket?.allowSelfSignedSSL = true
        }
        
        self.mWebSocket?.event.open = {
            self.mReconnection.onConnected()
        }
        
        self.mWebSocket?.event.close = { code, reason, clean in
            self.mPingHandler.stop()
            self.delegate?.onDisconnect(code: code, reason: reason)
            if self.mReconnection.isRunning() {
                return
            }
            if self.mReconnection.isAutoReconnectOn() && code != 1000 {
                self.mReconnection.reconnect()
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
                guard let decodedString = String(bytes: binary, encoding: .utf8) else {
                    self.delegate?.onError(error: CWSErrors.binaryDecodeError(binary))
                    return
                }
                string = decodedString
            }
            if string == "#0" {
                self.mPingHandler.resetMissedPing()
                self.send(event: "#1", data: nil, type: .ping)
            } else {
                self.mParser.handleMessage(with: string)
            }
        }
    }
    
    public func on(event: String, completion: @escaping CompletionHandler) {
        self.mEmitter.on(event: event, completion: completion)
    }
    
    public func subscribe(_ channelName: String) -> CWSChannel {
        var channel = self.mChannels.filter { $0.mChannelName == channelName }.map { $0 }.first
        if channel == nil {
            channel = CWSChannel(channelName: channelName, socket: self)
            self.mChannels.append(channel!)
        }
        return channel!
    }
    
    public func getChannels() -> [CWSChannel] {
        return self.mChannels
    }
    
    public func getChannel(by name: String) -> CWSChannel? {
        return self.mChannels.filter { $0.mChannelName == name }.first
    }
    
    public func disconnect(closeCode: Int? = nil, reason: String? = nil) {
        self.mWebSocket?.close(closeCode == nil ? 1000 : closeCode!, reason: reason == nil ? "" : reason!)
    }
    
    public func setReconnection(autoReconnect: Bool, reconnectionIntervalMin: Double? = nil, reconnectionIntervalMax: Double? = nil, reconnectionAttempts: Int? = nil) {
        self.mReconnection.setReconnection(autoReconnect: autoReconnect, reconnectionIntervalMin: reconnectionIntervalMin, reconnectionIntervalMax: reconnectionIntervalMax, reconnectionAttempts: reconnectionAttempts)
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
            guard let encodedData = self.mParser.encode(event: event,
                                                                      data: data,
                                                                      type: type)?.data(using: .utf8) else {
                                                                        self.delegate?.onError(error: CWSErrors.JSONStringifyError(data))
                                                                        return
            }
            self.mWebSocket?.send(encodedData)
        } else {
            guard let anyData = self.mParser.encode(event: event, data: data, type: type) else {
                self.delegate?.onError(error: CWSErrors.JSONStringifyError(data))
                return
            }
            self.mWebSocket?.send(anyData)
        }
    }
    
    open func setBinary(to binary: Bool) {
        self.mUseBinary = binary
    }
    
    open func emit(event: String, data: Any) {
        self.mEmitter.emit(event: event, data: data)
    }
    
    open func removeChannel(_ channel: CWSChannel) {
        self.mChannels = self.mChannels.filter { $0 != channel }
    }
    
    open func startPinging(with interval: TimeInterval) {
        self.mPingHandler.start(interval: interval, socket: self)
    }
}
