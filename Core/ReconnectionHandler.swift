//
//  ReconnectionHandler.swift
//  Test
//
//  Created by Roman Baitaliuk on 7/10/17.
//  Copyright © 2017 ByteKit. All rights reserved.
//

import Foundation

// MARK: Properties & Initialization
open class ReconnectionHandler {
    open var mReconnectionTimer: Timer?
    
    open var mAutoReconnect: Bool
    open var mReconnectionAttempts: Int
    open var mReconnectionIntervalMin: Double // reconnection interval is in seconds
    open var mReconnectionIntervalMax: Double // reconnection interval is in seconds
    
    private var currentReconnectionAttempted: Int = 0
    
    open var socket: ClusterWS?
    
    public init(autoReconnect: Bool? = nil, reconnectionIntervalMin: Double? = nil, reconnectionIntervalMax: Double? = nil, reconnectionAttempts: Int? = nil, socket: ClusterWS) {
        self.mAutoReconnect = autoReconnect != nil ? autoReconnect! : false
        self.mReconnectionIntervalMin = reconnectionIntervalMin != nil ? reconnectionIntervalMin! : 1.0
        self.mReconnectionIntervalMax = reconnectionIntervalMax != nil ? reconnectionIntervalMax! : 5.0
        self.mReconnectionAttempts = reconnectionAttempts != nil ? reconnectionAttempts! : 0
        self.socket = socket
    }
    
    public init() {
        self.mAutoReconnect = false
        self.mReconnectionIntervalMin = 1.0
        self.mReconnectionIntervalMax = 5.0
        self.mReconnectionAttempts = 0
    }
}

//MARK: Open methods
extension ReconnectionHandler {
    open func onConnected() {
        self.resetTimer()
        self.mReconnectionAttempts = 0
        
        let channels = self.socket?.getChannels()
        channels?.forEach { _ = socket?.subscribe($0.mChannelName) }
    }
    
    open func resetTimer() {
        self.mReconnectionTimer?.invalidate()
        self.mReconnectionTimer = nil
    }
    
    open func reconnect() {
        let max = UInt32(self.mReconnectionIntervalMax * 1000)
        let min = UInt32(self.mReconnectionIntervalMin * 1000)
        let randomNumber = arc4random_uniform(max-min)+min
        self.mReconnectionTimer = Timer.scheduledTimer(withTimeInterval: Double(randomNumber / 1000),
                                                       repeats: false,
                                                       block: { (timer) in
                                                        if self.socket?.getState() == .closed {
                self.currentReconnectionAttempted += 1
                if self.mReconnectionAttempts != 0 && self.currentReconnectionAttempted >= self.mReconnectionAttempts {
                    self.resetTimer()
                } else {
                    self.resetTimer()
                    self.socket?.connect()
                }
            }
        })
    }
}
