//
//  Options.swift
//  ClusterWS-Client-Swift
//
//  Created by Roman Baitaliuk on 3/10/17.
//

import Foundation

class Options {
    
    //MARK: Properties
    
    public let mUrl: String?;
    public let mPort: Int?;
    public let mAutoReconnect: Bool!;
    public let mReconnectionInterval: Int!;
    public let mReconnectionAttempts: Int!;
    
    //MARK: Initialization
    
    init(url: String, port: Int, autoReconnect: Bool? = nil, reconnectionInterval: Int? = nil, reconnectionAttempts: Int? = nil) {
        self.mUrl = url
        self.mPort = port
        self.mAutoReconnect = autoReconnect != nil ? autoReconnect : false
        self.mReconnectionInterval = reconnectionInterval != nil ? reconnectionInterval : 5000
        self.mReconnectionAttempts = reconnectionAttempts != nil ? reconnectionAttempts : 0
    }
}
