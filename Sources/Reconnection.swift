//
//  Reconnection.swift
//  Test
//
//  Created by Roman Baitaliuk on 7/10/17.
//  Copyright © 2017 ByteKit. All rights reserved.
//

import Foundation

class Reconnection {
    
    //MARK: Properties
    
    open var mAutoReconnect: Bool!
    open var mInReconnectionState: Bool!
    open var mReconnectionAttempts: Int!
    open var mReconnectionTimer: Timer?
    open let mReconnectionInterval: Double!
    
    //MARK: Open methods within ClsterWS
    
    init(autoReconnect: Bool?, reconnectionInterval: Double?, reconnectionAttempts: Int?) {
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
                self.mReconnectionAttempts = self.mReconnectionAttempts + 1
                if self.mReconnectionAttempts != 0 && self.mReconnectionAttempts >= self.mReconnectionAttempts {
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
