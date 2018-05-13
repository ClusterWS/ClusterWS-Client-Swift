//
//  CWSPing.swift
//  ClusterWSTests
//
//  Created by Roman Baitaliuk on 21/01/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import Foundation

open class CWSPing {
    
    // MARK: - Properties
    
    private var mPingTimer: Timer?
}

// MARK: - Open methods

extension CWSPing {
    
    open func stop() {
        self.mPingTimer?.invalidate()
        self.mPingTimer = nil
    }
    
    @objc private func executionBlock(_ socket: ClusterWS) {
        func block(_ socket: ClusterWS) {
            socket.disconnect(closeCode: 4001, reason: "No pings")
        }
        
        guard let userInfoWS = self.mPingTimer?.userInfo as? ClusterWS else {
            block(socket)
            return
        }
        
        block(userInfoWS)
    }
    
    open func restart(with interval: TimeInterval, socket: ClusterWS) {
        self.stop()
        if #available(iOS 10.0, *, OSX 10.12, tvOS 10.0, *) {
            self.mPingTimer = Timer.scheduledTimer(withTimeInterval: interval / 1000,
                                                   repeats: false,
                                                   block: { (timer) in
                                                    self.executionBlock(socket)
            })
        } else {
            self.mPingTimer = Timer(timeInterval: interval / 1000,
                                    target: self,
                                    selector: #selector(executionBlock(_:)),
                                    userInfo: socket,
                                    repeats: false)
            self.mPingTimer?.fire()
        }
    }
}
