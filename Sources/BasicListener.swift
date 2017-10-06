//
//  BasicListener.swift
//  ClusterWS-Client-Swift
//
//  Created by Roman Baitaliuk on 4/10/17.
//

import Foundation

protocol BasicListener: class {
    func onConnected()
    func onDisconnected(error: Error?)
//    func onConnectError(error: Error)
}
