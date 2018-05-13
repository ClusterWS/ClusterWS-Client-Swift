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
public protocol CWSDelegate: class {
    
    /// Called when socket is connected
    func onConnect()
    
    /// Called when socket disconnected
    func onDisconnect(code: Int?, reason: String?)
    
    /// Called on error
    /// - Parameter error: thrown error
    func onError(error: Error)
    
    func decode(message: Any?) -> Any?
    
    func encode(message: Any?) -> Any?
}

extension CWSDelegate {
    
    /// Custom decode that user can implement
    func decode(message: Any?) -> Any? {
        return nil
    }
    
    /// Custom encode that user can implement
    func encode(message: Any?) -> Any? {
        return nil
    }
}
