//
//  Options.swift
//  ClusterWS-Client-Swift
//
//  Created by Roman Baitaliuk on 3/10/17.
//

import Foundation

class Options {
    private var mUrl: String!;
    private var mPort: Int!;
    private var mAutoReconnect: Bool!;
    private var mReconnectionInterval: Int!;
    private var mReconnectionAttempts: Int!;
    
    init(url: String, port: Int, autoReconnect: Bool? = nil, reconnectionInterval: Int? = nil, reconnectionAttempts: Int? = nil) {
        self.mUrl = url
        self.mPort = port
        self.mAutoReconnect = autoReconnect != nil ? autoReconnect : false
        self.mReconnectionInterval = reconnectionInterval != nil ? reconnectionInterval : 5000
        self.mReconnectionAttempts = reconnectionAttempts != nil ? reconnectionAttempts : 0
    }
    
    public func getUrl() -> String {
        return self.mUrl
    }
    
    public func getPort() -> Int{
        return self.mPort
    }
    
    public func getAutoReconnect() -> Bool {
        return self.mAutoReconnect
    }
    
    public func getReconnectionInterval() -> Int {
        return self.mReconnectionInterval
    }
    
    public func getReconnectionAttempts() -> Int {
        return self.mReconnectionAttempts
    }
}
