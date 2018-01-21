//
//  PingHandler.swift
//  ClusterWSTests
//
//  Created by Roman Baitaliuk on 21/01/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import Foundation

// MARK: Properties & Initialization
open class PingHandler {
    open var mMissedPing: Int = 0
    open var mPingTimer: Timer?
}

//MARK: Open methods
extension PingHandler {
    open func resetMissedPing() {
        self.mMissedPing = 0
    }
    
    open func resetPingTimer() {
        self.mPingTimer?.invalidate()
        self.mPingTimer = nil
    }
    
    open func reset() {
        self.mMissedPing = 0
        self.resetPingTimer()
    }
    
    open func runPingTimer(interval: TimeInterval, socket: ClusterWS) {
        self.mPingTimer = Timer.scheduledTimer(withTimeInterval: interval / 1000, repeats: true, block: { (timer) in
            if self.mMissedPing < 3 {
                self.mMissedPing += 1
            } else {
                if socket.getState() != .closed {
                    socket.disconnect(closeCode: 4001, reason: "No pings")
                    self.resetPingTimer()
                }
            }
        })
    }
}
