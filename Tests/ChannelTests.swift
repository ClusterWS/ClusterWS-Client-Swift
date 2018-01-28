//
//  ChannelTests.swift
//  ClusterWSTestsTests
//
//  Created by Roman Baitaliuk on 10/10/17.
//  Copyright © 2017 ByteKit. All rights reserved.
//

import XCTest
@testable import ClusterWSTests

class ChannelTests: XCTestCase {
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
    
    func testGetChannel() {
        self.webSocket.connect()
        let connectionExpectation = expectation(description: "connection expectation")
        Timer.scheduledTimer(withTimeInterval: 1.9, repeats: false) { (_) in
            if self.webSocket.getState() == .open {
                connectionExpectation.fulfill()
            }
        }
        wait(for: [connectionExpectation], timeout: 2.0)
        let channelName = "test channel"
        let subscribedChannel = self.webSocket.subscribe(channelName)
        let recievedChannel = self.webSocket.getChannel(by: channelName)
        XCTAssertEqual(subscribedChannel, recievedChannel)
    }
    
    func testGetAllChannels() {
        self.webSocket.connect()
        let connectionExpectation = expectation(description: "connection expectation")
        Timer.scheduledTimer(withTimeInterval: 1.9, repeats: false) { (_) in
            if self.webSocket.getState() == .open {
                connectionExpectation.fulfill()
            }
        }
        wait(for: [connectionExpectation], timeout: 2.0)
        let channels = ["first channel", "second channel", "third channel"]
        _ = channels.map { self.webSocket.subscribe($0) }
        let recievedChannels = self.webSocket.getChannels().map { $0.mChannelName }
        XCTAssertEqual(channels, recievedChannels)
    }
    
    func testUnsubscribe() {
        self.webSocket.connect()
        let connectionExpectation = expectation(description: "connection expectation")
        Timer.scheduledTimer(withTimeInterval: 1.9, repeats: false) { (_) in
            if self.webSocket.getState() == .open {
                connectionExpectation.fulfill()
            }
        }
        wait(for: [connectionExpectation], timeout: 2.0)
        let channelName = "test channel"
        let subscribedChannel = self.webSocket.subscribe(channelName)
        subscribedChannel.unsubscribe()
        let recievedChannel = self.webSocket.getChannel(by: channelName)
        XCTAssertEqual(nil, recievedChannel)
    }
}
