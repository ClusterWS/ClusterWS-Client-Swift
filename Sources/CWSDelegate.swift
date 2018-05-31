//
//  CWSDelegate.swift
//  ClusterWS-Client-Swift
//
//  Created by Roman Baitaliuk on 4/10/17.
//

import Foundation

/**
     ClusterWS delegate methods
*/
@objc public protocol CWSDelegate {
    
    /// Called when socket is connected
    func onConnect()
    
    /// Called when socket disconnected
    func onDisconnect(code: Int, reason: String)
    
    /// Called on error
    /// - Parameter error: thrown error
    func onError(error: Error)
    
    @objc optional func decode(message: Any?) -> Any?
    
    @objc optional func encode(message: Any?) -> Any?
}
