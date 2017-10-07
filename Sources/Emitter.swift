//
//  Emitter.swift
//  ClusterWS-Client-Swift
//
//  Created by Roman Baitaliuk on 3/10/17.
//

import Foundation

//MARK: Callback

typealias Listener = (Any) -> Void

class Emitter {
    
    //MARK: Properties
    
    private var mEvents: [(string: String, function: Listener)]!
    
    //MARK: Initialization
    
    init() {
        self.mEvents = []
    }
    
    //MARK: Public methods
    
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




