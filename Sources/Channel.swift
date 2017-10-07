//
//  Channel.swift
//  Test
//
//  Created by Roman Baitaliuk on 6/10/17.
//  Copyright © 2017 ByteKit. All rights reserved.
//

import Foundation

class Channel: Equatable {
    
    //channel object comparisment
    static func ==(lhs: Channel, rhs: Channel) -> Bool {
        if lhs.mChannelName == rhs.mChannelName {
            return true
        } else {
            return false
        }
    }
    
    //MARK: Properties
    
    public let mChannelName: String!
    private var listener: Listener?
    private let mSocket: ClusterWS!
    
    //MARK: Initialization
    
    init(channelName: String, socket: ClusterWS) {
        self.mChannelName = channelName
        self.mSocket = socket
        self.subscribe()
    }
    
    
    //MARK: Public functions
    
    public func watch(fn: @escaping Listener) -> Channel {
        self.listener = fn
        return self
    }
    
    public func publish(data: Any) -> Channel {
        self.mSocket.send(event: self.mChannelName, data: data, type: .publish)
        return self
    }
    
    public func unsubscribe() {
        self.mSocket.send(event: "unsubscribe", data: self.mChannelName, type: .system)
        self.mSocket.mChannels = self.mSocket.mChannels.filter { $0 != self }
    }
    
    //MARK: ClusterWS internal functions
    
    open func subscribe() {
        self.mSocket.send(event: "subscribe", data: self.mChannelName, type: .system)
    }
    
    open func onMessage(data: Any) {
        if let fn = self.listener {
            fn(data)
        }
    }
}
