//
//  CWSReconnectionTests.swift
//  CWSTests
//
//  Created by Roman Baitaliuk on 4/02/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import XCTest
import ClusterWS_Client_Swift

extension CWSReconnectionTests: CWSDelegate {
    func onConnect() {
        print("Connected")
    }
    
    func onDisconnect(code: Int?, reason: String?) {
        print("Disconnected")
        self.currentAttamts += 1
    }
    
    func onError(error: Error) {
        print(error.localizedDescription)
    }
}

class CWSReconnectionTests: XCTestCase {
    var webSocket: ClusterWS!
    let reconnectionIntervalMin = 1.0
    let reconnectionIntervalMax = 3.0
    let reconnectionAttempts = 3
    
    var currentAttamts = 0
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.webSocket = ClusterWS(url: "wss://localhost:0000")
        self.webSocket.delegate = self
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        self.currentAttamts = 0
    }
    
    /**
         Make sure your localhost server shut down or you're using wrong ClusterWS url.
     */
    func testReconnectionAttamts() {
        self.webSocket.setReconnection(autoReconnect: true, reconnectionIntervalMin: reconnectionIntervalMin, reconnectionIntervalMax: reconnectionIntervalMax, reconnectionAttempts: reconnectionAttempts)
        self.webSocket.connect()
        let timeout = reconnectionIntervalMax * Double(reconnectionAttempts)
        let connectionExpectation = expectation(description: "connection expectation")
        Timer.scheduledTimer(withTimeInterval: timeout - 0.1, repeats: false) { (_) in
            if self.currentAttamts == self.reconnectionAttempts {
                connectionExpectation.fulfill()
            }
        }
        wait(for: [connectionExpectation], timeout: timeout)
    }
    
    /**
         Make sure your localhost server shut down or you're using wrong ClusterWS url.
     */
    func testAutoReconnect() {
        self.webSocket.setReconnection(autoReconnect: true, reconnectionIntervalMin: reconnectionIntervalMin, reconnectionIntervalMax: reconnectionIntervalMax, reconnectionAttempts: reconnectionAttempts)
        self.webSocket.connect()
        let timeout = reconnectionIntervalMax * Double(reconnectionAttempts)
        let connectionExpectation = expectation(description: "connection expectation")
        Timer.scheduledTimer(withTimeInterval: timeout - 0.1, repeats: false) { (_) in
            if self.currentAttamts > 1 {
                connectionExpectation.fulfill()
            }
        }
        wait(for: [connectionExpectation], timeout: timeout)
    }
}
