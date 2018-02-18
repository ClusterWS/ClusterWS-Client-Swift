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
        wait(for: [connectionExpectation], timeout: 5.0)
        let channelName = "test channel"
        let currentString = "test string"
        _ = self.webSocket.subscribe(channelName).publish(data: currentString).watch { (data) in
            guard let recievedString = data as? String else {
                return XCTFail()
            }
            XCTAssertEqual(recievedString, currentString)
        }
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
        wait(for: [connectionExpectation], timeout: 5.0)
        let channelName = "test channel"
        let currentInt = 30
        _ = self.webSocket.subscribe(channelName).publish(data: currentInt).watch { (data) in
            guard let recievedInt = data as? String else {
                return XCTFail()
            }
            XCTAssertEqual(currentInt, Int(recievedInt))
        }
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
        wait(for: [connectionExpectation], timeout: 5.0)
        let channelName = "test channel"
        let key = "id"
        let value = 0
        let currentDictionary = [key: value]
        _ = self.webSocket.subscribe(channelName).publish(data: currentDictionary).watch { (data) in
            guard let recievedDictionaryString = data as? String else {
                return XCTFail()
            }
            if !recievedDictionaryString.contains(key) && !recievedDictionaryString.contains(String(value)) {
                return XCTFail()
            }
        }
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
        wait(for: [connectionExpectation], timeout: 5.0)

        let channelName = "test channel"
        let value1 = 30
        let value2 = "test"
        let currentArray = [value1, value2] as [Any]
        _ = self.webSocket.subscribe(channelName).publish(data: currentArray).watch { (data) in
            guard let recievedArrayString = data as? String else {
                return XCTFail()
            }
            if !recievedArrayString.contains(String(value1)) && !recievedArrayString.contains(value2) {
                return XCTFail()
            }
        }
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
        wait(for: [connectionExpectation], timeout: 5.0)
        
        let channelName = "test channel"
        let currentBoolean = false
        _ = self.webSocket.subscribe(channelName).publish(data: currentBoolean).watch { (data) in
            guard let recievedBooleanStringNumber = data as? String else {
                return XCTFail()
            }
            if recievedBooleanStringNumber == "0" || recievedBooleanStringNumber == "1" {
                XCTAssertEqual(Int(recievedBooleanStringNumber), currentBoolean.hashValue)
            } else {
                XCTFail()
            }
        }
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
