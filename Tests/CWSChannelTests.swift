//
//  CWSChannelTests.swift
//  CWSTests
//
//  Created by Roman Baitaliuk on 10/10/17.
//  Copyright © 2017 ByteKit. All rights reserved.
//

import XCTest
import ClusterWS_Client_Swift

class CWSChannelTests: XCTestCase {
    var webSocket: ClusterWS!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.webSocket = ClusterWS(url: "wss://localhost:8080")
        self.webSocket.setReconnection(autoReconnect: true)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        self.webSocket.disconnect()
    }
    
    func testGetChannel() {
        self.webSocket.connect()
        let connectionExpectation = expectation(description: "connection expectation")
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            if self.webSocket.getState() == .open {
                connectionExpectation.fulfill()
                timer.invalidate()
            }
        }
        wait(for: [connectionExpectation], timeout: 5.0)
        
        let channelName = "test channel"
        let subscribedChannel = self.webSocket.subscribe(channelName)
        let recievedChannel = self.webSocket.getChannel(by: channelName)
        XCTAssertEqual(subscribedChannel, recievedChannel)
    }
    
    func testGetAllChannels() {
        self.webSocket.connect()
        let connectionExpectation = expectation(description: "connection expectation")
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            if self.webSocket.getState() == .open {
                connectionExpectation.fulfill()
                timer.invalidate()
            }
        }
        wait(for: [connectionExpectation], timeout: 5.0)
        
        let channels = ["first channel", "second channel", "third channel"]
        _ = channels.map { self.webSocket.subscribe($0) }
        let recievedChannels = self.webSocket.getChannels().map { $0.mChannelName }
        XCTAssertEqual(channels, recievedChannels)
    }
    
    func testPublishWatchString() {
        self.webSocket.connect()
        let connectionExpectation = expectation(description: "connection expectation")
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            if self.webSocket.getState() == .open {
                connectionExpectation.fulfill()
                timer.invalidate()
            }
        }
        
        let publishWatchExpectation = expectation(description: "publish and watch expectation result")
        let channelName = "test channel"
        let currentString = "test string"
        _ = self.webSocket.subscribe(channelName).publish(data: currentString).watch { (data) in
            guard let recievedString = data as? String else {
                return XCTFail()
            }
            XCTAssertEqual(recievedString, currentString)
            publishWatchExpectation.fulfill()
        }
        wait(for: [connectionExpectation, publishWatchExpectation], timeout: 5.0)
    }
    
    func testPublishWatchInt() {
        self.webSocket.connect()
        let connectionExpectation = expectation(description: "connection expectation")
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            if self.webSocket.getState() == .open {
                connectionExpectation.fulfill()
                timer.invalidate()
            }
        }
        
        let publishWatchExpectation = expectation(description: "publish and watch expectation result")
        let channelName = "test channel"
        let currentInt = 30
        _ = self.webSocket.subscribe(channelName).publish(data: currentInt).watch { (data) in
            guard let recievedInt = data as? Int else {
                return XCTFail()
            }
            XCTAssertEqual(currentInt, recievedInt)
            publishWatchExpectation.fulfill()
        }
        
        wait(for: [connectionExpectation, publishWatchExpectation], timeout: 5.0)
    }
    
    func testPublishWatchDictionary() {
        self.webSocket.connect()
        let connectionExpectation = expectation(description: "connection expectation")
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            if self.webSocket.getState() == .open {
                connectionExpectation.fulfill()
                timer.invalidate()
            }
        }
        
        let publishWatchExpectation = expectation(description: "publish and watch expectation result")
        let channelName = "test channel"
        let currentDictionary = ["id": 0]
        _ = self.webSocket.subscribe(channelName).publish(data: currentDictionary).watch { (data) in
            guard let recievedDictionary = data as? [String: Int] else {
                return XCTFail()
            }
            XCTAssertEqual(recievedDictionary, currentDictionary)
            publishWatchExpectation.fulfill()
        }
        
        wait(for: [connectionExpectation, publishWatchExpectation], timeout: 5.0)
    }
    
    func testPublishWatchArray() {
        self.webSocket.connect()
        let connectionExpectation = expectation(description: "connection expectation")
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            if self.webSocket.getState() == .open {
                connectionExpectation.fulfill()
                timer.invalidate()
            }
        }

        let publishWatchExpectation = expectation(description: "publish and watch expectation result")
        let channelName = "test channel"
        let value1 = "30"
        let value2 = "test"
        let currentArray = [value1, value2] as [String]
        _ = self.webSocket.subscribe(channelName).publish(data: currentArray).watch { (data) in
            guard let recievedArray = data as? [String] else {
                return XCTFail()
            }
            XCTAssertEqual(recievedArray, currentArray)
            publishWatchExpectation.fulfill()
        }
        
        wait(for: [connectionExpectation, publishWatchExpectation], timeout: 5.0)
    }
    
    func testPublishWatchBoolean() {
        self.webSocket.connect()
        let connectionExpectation = expectation(description: "connection expectation")
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            if self.webSocket.getState() == .open {
                connectionExpectation.fulfill()
                timer.invalidate()
            }
        }
        
        let publishWatchExpectation = expectation(description: "publish and watch expectation result")
        let channelName = "test channel"
        let currentBoolean = false
        _ = self.webSocket.subscribe(channelName).publish(data: currentBoolean).watch { (data) in
            guard let recievedBoolean = data as? Bool else {
                return XCTFail()
            }
            XCTAssertEqual(recievedBoolean, currentBoolean)
            publishWatchExpectation.fulfill()
        }
        
        wait(for: [connectionExpectation, publishWatchExpectation], timeout: 5.0)
    }
    
    func testUnsubscribe() {
        self.webSocket.connect()
        let connectionExpectation = expectation(description: "connection expectation")
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            if self.webSocket.getState() == .open {
                connectionExpectation.fulfill()
                timer.invalidate()
            }
        }
        wait(for: [connectionExpectation], timeout: 5.0)
        
        let channelName = "test channel"
        let subscribedChannel = self.webSocket.subscribe(channelName)
        subscribedChannel.unsubscribe()
        let recievedChannel = self.webSocket?.getChannel(by: channelName)
        XCTAssertEqual(nil, recievedChannel)
    }
}
