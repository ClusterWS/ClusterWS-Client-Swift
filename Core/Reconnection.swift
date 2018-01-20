//
//  Reconnection.swift
//  Test
//
//  Created by Roman Baitaliuk on 7/10/17.
//  Copyright © 2017 ByteKit. All rights reserved.
//

import Foundation

open class Reconnection {
    
    //MARK: Properties
    
    open var mAutoReconnect: Bool!
    open var mInReconnectionState: Bool!
    open var mReconnectionAttempts: Int!
    open var mReconnectionTimer: Timer?
    open let mReconnectionIntervalMin: Double! //reconnection interval is in seconds
    open let mReconnectionIntervalMax: Double! //reconnection interval is in seconds
    
    private var currentReconnectionAttempted: Int = 0
    
    private var socket: ClusterWS!
    
    //MARK: Open methods within ClsterWS
    
    public init(autoReconnect: Bool?, reconnectionIntervalMin: Double?, reconnectionIntervalMax: Double?, reconnectionAttempts: Int?, socket: ClusterWS) {
        self.mAutoReconnect = autoReconnect != nil ? autoReconnect : false
        self.mReconnectionIntervalMin = reconnectionIntervalMin != nil ? reconnectionIntervalMin : 1.0
        self.mReconnectionIntervalMax = reconnectionIntervalMax != nil ? reconnectionIntervalMax : 5.0
        self.mReconnectionAttempts = reconnectionAttempts != nil ? reconnectionAttempts : 0
        self.mInReconnectionState = false
        self.socket = socket
    }
    
    open func onConnected() {
        self.mReconnectionTimer?.invalidate()
        self.mInReconnectionState = false
        self.mReconnectionAttempts = 0
        
        let channels = self.socket.getChannels()
        _ = channels.map { socket.subscribe($0.mChannelName) }
    }
    
    open func reconnect() {
        self.mInReconnectionState = true
        let max = UInt32(self.mReconnectionIntervalMax * 1000)
        let min = UInt32(self.mReconnectionIntervalMin * 1000)
        let randomNumber = arc4random_uniform(max-min)+min
        self.mReconnectionTimer = Timer.scheduledTimer(withTimeInterval: Double(randomNumber/1000), repeats: false, block: { (timer) in
            if self.socket.getState() == .closed {
                self.currentReconnectionAttempted += 1
                if self.mReconnectionAttempts != 0 && self.currentReconnectionAttempted >= self.mReconnectionAttempts {
                    timer.invalidate()
                    self.mAutoReconnect = false
                    self.mInReconnectionState = false
                } else {
                    self.socket.connect()
                }
            }
        })
    }
}
