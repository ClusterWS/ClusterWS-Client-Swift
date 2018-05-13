//
//  ClusterWSTests.swift
//  CWSTests
//
//  Created by Roman Baitaliuk on 9/10/17.
//  Copyright © 2017 ByteKit. All rights reserved.
//

import XCTest

@testable import ClusterWS
class ClusterWSTests: XCTestCase {
    var webSocket: ClusterWS!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.webSocket = ClusterWS(url: "ws://localhost:8080")
        self.webSocket.setReconnection(autoReconnect: true)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        self.webSocket.disconnect()
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
        
        let sendOnExpectation = expectation(description: "send and on expectation result")
        let currentString = "test string"
        
        self.webSocket.send(event: "String", data: currentString)
        self.webSocket.on(event: "String") { (data) in
            guard let recievedString = data as? String else {
                return XCTFail()
            }
            XCTAssertEqual(recievedString, currentString)
            sendOnExpectation.fulfill()
        }
        waitForExpectations(timeout: 5.0)
    }
    
    func testSendOnInt() {
        self.testOnConnect()
        
        let sendOnExpectation = expectation(description: "send and on expectation result")
        let currentInt = 30
        
        self.webSocket.send(event: "Number", data: currentInt)
        self.webSocket.on(event: "Number") { (data) in
            guard let recievedInt = data as? Int else {
                return XCTFail()
            }
            
            XCTAssertEqual(recievedInt, currentInt)
            sendOnExpectation.fulfill()
        }
        waitForExpectations(timeout: 5.0)
    }
    
    func testSendOnArray() {
        self.testOnConnect()
        
        let sendOnExpectation = expectation(description: "send and on expectation result")
        let currentArray: [Int] = [30, 20]
        
        self.webSocket.send(event: "Array", data: currentArray)
        self.webSocket.on(event: "Array") { (data) in
            guard let recievedArray = data as? [Int] else {
                return XCTFail()
            }
            
            XCTAssertEqual(recievedArray, currentArray)
            sendOnExpectation.fulfill()
        }
        waitForExpectations(timeout: 5.0)
    }
    
    func testSendOnDictionary() {
        self.testOnConnect()
        
        let sendOnExpectation = expectation(description: "send and on expectation result")
        let currentObject = ["object": 0]
        
        self.webSocket.send(event: "Object", data: currentObject)
        self.webSocket.on(event: "Object") { (data) in
            guard let recievedObject = data as? [String: Int] else {
                return XCTFail()
            }
            
            XCTAssertEqual(recievedObject, currentObject)
            sendOnExpectation.fulfill()
        }
        waitForExpectations(timeout: 5.0)
    }
    
    func testSendOnBoolean() {
        self.testOnConnect()
        
        let sendOnExpectation = expectation(description: "send and on expectation result")
        let currentBoolean = true
        
        self.webSocket.send(event: "Boolean", data: currentBoolean)
        self.webSocket.on(event: "Boolean") { (data) in
            guard let recievedBoolean = data as? Bool else {
                return XCTFail()
            }
            
            XCTAssertEqual(recievedBoolean, currentBoolean)
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
