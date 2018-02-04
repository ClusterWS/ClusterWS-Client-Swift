//
//  ClusterWSTests.swift
//  CWSTests
//
//  Created by Roman Baitaliuk on 9/10/17.
//  Copyright © 2017 ByteKit. All rights reserved.
//

import XCTest
import ClusterWS_Client_Swift

class ClusterWSTests: XCTestCase {
    var webSocket: ClusterWS!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.webSocket = ClusterWS(url: "wss://localhost:8080")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testOnConnect() {
        self.webSocket.connect()
        let connectExpectation = expectation(description: "connect expectation")
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            if self.webSocket.getState() == .open {
                timer.invalidate()
                connectExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5.0, handler: nil)
        XCTAssertEqual(self.webSocket.getState(), .open)
    }
    
    func testSendOnString() {
        self.testOnConnect()
        
        let sendOnExpectation = expectation(description: "Send, on expectation result")
        
        self.webSocket.send(event: "String", data: "test string")
        self.webSocket.on(event: "String") { (data) in
            guard ((data as? String) != nil) else {
                return XCTFail()
            }
            sendOnExpectation.fulfill()
        }
        waitForExpectations(timeout: 5.0)
    }
    
    func testSendOnInt() {
        self.testOnConnect()
        
        let sendOnExpectation = expectation(description: "Send, on expectation result")
        
        self.webSocket.send(event: "Int", data: 30)
        self.webSocket.on(event: "Int") { (data) in
            guard ((data as? Int) != nil) else {
                return XCTFail()
            }
            sendOnExpectation.fulfill()
        }
        waitForExpectations(timeout: 5.0)
    }
    
    func testSendOnArray() {
        self.testOnConnect()
        
        let sendOnExpectation = expectation(description: "Send, on expectation result")
        
        self.webSocket.send(event: "Array", data: [30,23])
        self.webSocket.on(event: "Array") { (data) in
            guard ((data as? [Any]) != nil) else {
                return XCTFail()
            }
            sendOnExpectation.fulfill()
        }
        waitForExpectations(timeout: 5.0)
    }
    
    func testSendOnDictionary() {
        self.testOnConnect()
        let sendOnExpectation = expectation(description: "Send, on expectation result")
        self.webSocket.send(event: "Dictionary", data: ["id": 0])
        self.webSocket.on(event: "Dictionary") { (data) in
            guard ((data as? [String: Any]) != nil) else {
                return XCTFail()
            }
            sendOnExpectation.fulfill()
        }
        waitForExpectations(timeout: 5.0)
    }
    
    func testPingPong() {
        self.testOnConnect()
        let pingPongExpectation = expectation(description: "ping pong expectation")
        Timer.scheduledTimer(withTimeInterval: 1.4, repeats: false) { (_) in
            pingPongExpectation.fulfill()
        }
        wait(for: [pingPongExpectation], timeout: 1.5)
        XCTAssertEqual(self.webSocket.getState(), .open)
    }
    
    func testDisconnect() {
        self.testOnConnect()
        
        let disconnectExpectation = expectation(description: "disconnect expectation")
        self.webSocket.disconnect()
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            if self.webSocket.getState() == .closed {
                disconnectExpectation.fulfill()
                timer.invalidate()
            }
        }
        wait(for: [disconnectExpectation], timeout: 5.0)
    }
    
    func testGetState() {
        //open state
        self.testOnConnect()
        XCTAssertEqual(self.webSocket.getState(), .open)
        
        self.testDisconnect()
        XCTAssertEqual(self.webSocket.getState(), .closed)
    }
    
}
