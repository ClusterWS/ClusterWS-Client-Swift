//
//  CWSReconnectionTests.swift
//  CWSTests
//
//  Created by Roman Baitaliuk on 4/02/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import XCTest
import ClusterWS_Client_Swift

//@testable import ClusterWS
extension CWSReconnectionTests: CWSDelegate {
    
    func onConnect() {
        print("Connected")
    }
    
    func onDisconnect(code: Int, reason: String) {
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
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        self.currentAttamts = 0
        self.webSocket.disconnect()
    }
    
    private func initSocketWithWrongUrl() {
        self.webSocket = ClusterWS(url: "ws://localhost:0000")
        self.webSocket.delegate = self
    }
    
    private func initSocketWithRightUrl() {
        self.webSocket = ClusterWS(url: "ws://localhost:8080")
        self.webSocket.delegate = self
    }
    
    func testReconnectionAttemts() {
        self.initSocketWithWrongUrl()
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
    
    func testAutoReconnectTrue() {
        self.initSocketWithRightUrl()
        self.webSocket.setReconnection(autoReconnect: true, reconnectionIntervalMin: reconnectionIntervalMin, reconnectionIntervalMax: reconnectionIntervalMax, reconnectionAttempts: reconnectionAttempts)
        self.webSocket.connect()
        self.webSocket.disconnect(closeCode: 1001, reason: "Reconnection test disconnect")
        let connectionExpectation = expectation(description: "connection expectation")
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            if self.webSocket.getState() == .open {
                timer.invalidate()
                connectionExpectation.fulfill()
            }
        }
        wait(for: [connectionExpectation], timeout: 5.0)
        XCTAssertEqual(self.webSocket.getState(), .open)
    }
    
    func testAutoReconnectFalse() {
        self.initSocketWithRightUrl()
        self.webSocket.setReconnection(autoReconnect: false, reconnectionIntervalMin: reconnectionIntervalMin, reconnectionIntervalMax: reconnectionIntervalMax, reconnectionAttempts: reconnectionAttempts)
        self.webSocket.connect()
        self.webSocket.disconnect(closeCode: 1001, reason: "Reconnection test disconnect")
        let connectionExpectation = expectation(description: "connection expectation")
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            if self.webSocket.getState() == .closed {
                timer.invalidate()
                connectionExpectation.fulfill()
            }
        }
        wait(for: [connectionExpectation], timeout: 5.0)
        XCTAssertEqual(self.webSocket.getState(), .closed)
    }
}
