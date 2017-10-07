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
    open let mReconnectionInterval: Double! //reconnection interval is in seconds
    
    private var currentReconnectionAttempted: Int = 0
    
    //MARK: Open methods within ClsterWS
    
    public init(autoReconnect: Bool?, reconnectionInterval: Double?, reconnectionAttempts: Int?) {
        self.mAutoReconnect = autoReconnect != nil ? autoReconnect : false
        self.mReconnectionInterval = reconnectionInterval != nil ? reconnectionInterval : 5.0
        self.mReconnectionAttempts = reconnectionAttempts != nil ? reconnectionAttempts : 0
        self.mInReconnectionState = false
    }
    
    open func onConnected() {
        self.mReconnectionTimer?.invalidate()
        self.mInReconnectionState = false
        self.mReconnectionAttempts = 0
    }
    
    open func reconnect(socket: ClusterWS) {
        self.mInReconnectionState = true
        self.mReconnectionTimer = Timer.scheduledTimer(withTimeInterval: self.mReconnectionInterval, repeats: true, block: { (_) in
            if socket.getState() == .closed {
                self.currentReconnectionAttempted += 1
                if self.mReconnectionAttempts != 0 && self.currentReconnectionAttempted >= self.mReconnectionAttempts {
                    self.mReconnectionTimer?.invalidate()
                    self.mAutoReconnect = false
                    self.mInReconnectionState = false
                } else {
                    socket.connect()
                }
            }
        })
    }
    
}
