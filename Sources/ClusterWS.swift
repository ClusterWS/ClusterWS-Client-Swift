//
//  ClusterWS.swift
//  ClusterWS-Client-Swift
//
//  Created by Roman Baitaliuk on 3/10/17.
//

import Foundation

open class ClusterWS: NSObject {

    // MARK: - Properties

    public var delegate: CWSDelegate?

    // MARK: - Internal

    private var mChannels: [CWSChannel] = []
    private var mWebSocket: WebSocket?

    // MARK: - Dependencies

    private let mEmitter: CWSEmitter
    private let mPingHandler: CWSPing
    private lazy var mReconnection = CWSReconnection(socket: self)
    private lazy var mParser = CWSParser(socket: self)

    // MARK: - Settings

    private var mPingInterval: TimeInterval?
    private var mUseBinary: Bool = false
    private let mUrl: String
    private var mPingBinary: Data!

    // MARK: - Static

    static let mPingMessage: String = "A"

    public init(url: String) {
        self.mUrl = url
        self.mEmitter = CWSEmitter()
        self.mPingHandler = CWSPing()
    }
}

// MARK: - Public methods

extension ClusterWS {

    public func connect() {
        guard let url = URL(string: self.mUrl) else {
            self.delegate?.onError(error: CWSError.invalidURL(self.mUrl))
            return
        }

        guard let binary = self.mParser.encode(message: ClusterWS.mPingMessage) else {
            self.delegate?.onError(error: CWSError.binaryEncodeError(ClusterWS.mPingMessage))
            return
        }

        self.mPingBinary = binary

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
            if let binary = message as? [UInt8] {
                if binary.first == 57 {
                    self.mWebSocket?.send(data: self.mPingBinary)
                    guard let interval =  self.mPingInterval else {
                        self.delegate?.onError(error: CWSError.failedToCastPingTimer)
                        return
                    }
                    self.resetPing(with: interval)
                    return
                } else {
                    guard let decodedString = String(bytes: binary, encoding: .utf8) else {
                        self.delegate?.onError(error: CWSError.binaryDecodeError(binary))
                        return
                    }
                    string = decodedString
                }
            }
            if let text = message as? String {
                string = text
            }
            self.mParser.handleMessage(with: string)
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

// MARK: - Open methods

extension ClusterWS {
    open func send(event: String, data: Any? = nil, type: MessageType) {
        let customEncodedData = self.delegate?.encode?(message: data) ?? data
        if self.mUseBinary {
            guard let encodedData = self.mParser.encode(event: event,
                                                                      data: customEncodedData,
                                                                      type: type)?.data(using: .utf8) else {
                                                                        self.delegate?.onError(error: CWSError.JSONStringifyError(data))
                                                                        return
            }
            self.mWebSocket?.send(encodedData)
        } else {
            guard let anyData = self.mParser.encode(event: event, data: customEncodedData, type: type) else {
                self.delegate?.onError(error: CWSError.JSONStringifyError(data))
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

    open func removeEvent(_ event: String) {
      self.mEmitter.remove(event: event)
    }

    open func removeAllEvents() {
      self.mEmitter.removeAllEvents()
    }

    open func removeChannel(_ channel: CWSChannel) {
        self.mChannels = self.mChannels.filter { $0 != channel }
    }

    open func resetPing(with interval: TimeInterval) {
        self.mPingHandler.restart(with: interval, socket: self)
    }

    open func setPingInterval(_ interval: TimeInterval) {
        self.mPingInterval = interval
        self.resetPing(with: interval)
    }
}
