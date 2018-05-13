//
//  CWSChannel.swift
//  Test
//
//  Created by Roman Baitaliuk on 6/10/17.
//  Copyright © 2017 ByteKit. All rights reserved.
//

import Foundation

open class CWSChannel: Equatable {
    
    // MARK: - Properties
    
    public static func ==(lhs: CWSChannel, rhs: CWSChannel) -> Bool {
        if lhs.mChannelName == rhs.mChannelName {
            return true
        } else {
            return false
        }
    }
    
    public let mChannelName: String
    private var mCompletion: CompletionHandler?
    private let mSocket: ClusterWS
    
    // MARK: - Init
    
    public init(channelName: String, socket: ClusterWS) {
        self.mChannelName = channelName
        self.mSocket = socket
        self.subscribe()
    }
}

// MARK: - Public

extension CWSChannel {
    
    public func watch(completion: @escaping CompletionHandler) -> CWSChannel {
        self.mCompletion = completion
        return self
    }
    
    public func publish(data: Any) -> CWSChannel {
        self.mSocket.send(event: self.mChannelName, data: data, type: .publish)
        return self
    }
    
    public func unsubscribe() {
        self.mSocket.send(event: SystemEventType.unsubscribe.rawValue, data: self.mChannelName, type: .system)
        self.mSocket.removeChannel(self)
    }
}

// MARK: - Open methods

extension CWSChannel {
    
    open func onMessage(data: Any) {
        if let completion = self.mCompletion {
            completion(data)
        }
    }
}

// MARK: - Private methods

extension CWSChannel {
    
    private func subscribe() {
        self.mSocket.send(event: SystemEventType.subscribe.rawValue, data: self.mChannelName, type: .system)
    }
}
