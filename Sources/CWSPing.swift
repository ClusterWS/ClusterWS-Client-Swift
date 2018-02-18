//
//  CWSPing.swift
//  ClusterWSTests
//
//  Created by Roman Baitaliuk on 21/01/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import Foundation

// MARK: Properties & Initialization
open class CWSPing {
    private var mMissedPing: Int = 0
    private var mPingTimer: Timer?
}

//MARK: Open methods
extension CWSPing {
    open func resetMissedPing() {
        self.mMissedPing = 0
    }
    
    private func resetPingTimer() {
        self.mPingTimer?.invalidate()
        self.mPingTimer = nil
    }
    
    @objc private func executionBlock(_ socket: ClusterWS) {
        func block(_ socket: ClusterWS) {
            if self.mMissedPing < 3 {
                self.mMissedPing += 1
            } else {
                if socket.getState() != .closed {
                    socket.disconnect(closeCode: 4001, reason: "No pings")
                    self.resetPingTimer()
                }
            }
        }
        
        guard let userInfoWS = self.mPingTimer?.userInfo as? ClusterWS else {
            block(socket)
            return
        }
        
        block(userInfoWS)
    }
    
    open func stop() {
        self.mMissedPing = 0
        self.resetPingTimer()
    }
    
    open func start(interval: TimeInterval, socket: ClusterWS) {
        if #available(iOS 10.0, *, OSX 10.12, tvOS 10.0, *) {
            self.mPingTimer = Timer.scheduledTimer(withTimeInterval: interval / 1000,
                                                   repeats: true,
                                                   block: { (timer) in
                                                    self.executionBlock(socket)
            })
        } else {
            self.mPingTimer = Timer(timeInterval: interval,
                                    target: self,
                                    selector: #selector(executionBlock(_:)),
                                    userInfo: socket,
                                    repeats: true)
            self.mPingTimer?.fire()
        }
    }
}
