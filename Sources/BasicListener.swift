//
//  BasicListener.swift
//  ClusterWS-Client-Swift
//
//  Created by Roman Baitaliuk on 4/10/17.
//

import Foundation

protocol BasicListener: class {
    func onConnect()
    func onDisconnect(code: Int?, reason: String?)
    func onError(error: Error)
}
