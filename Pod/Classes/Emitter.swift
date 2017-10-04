//
//  Emitter.swift
//  ClusterWS-Client-Swift
//
//  Created by Roman Baitaliuk on 3/10/17.
//

import Foundation

class Emitter {
    typealias Listener = (Any) -> Void
    
    private var mEvents: [(string: String, function: Listener)]!
    
    init() {
        self.mEvents = []
    }
    
    public func on(event: String, fn: @escaping Listener) {
        if let index = self.mEvents.index(where: { $0.0 == event }) {
            self.mEvents.remove(at: index)
        }
        
        mEvents.append((string: event, function: fn))
    }
    
    public func emit(event: String, data: Any) {
        if let index = self.mEvents.index(where: { $0.0 == event }) {
            self.mEvents[index].function(data)
        }
    }
    
    public func removeAllEvents() {
        self.mEvents.removeAll()
    }
}




