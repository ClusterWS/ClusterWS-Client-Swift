//
//  Emitter.swift
//  ClusterWS-Client-Swift
//
//  Created by Roman Baitaliuk on 3/10/17.
//

import Foundation

public typealias CompletionHandler = (Any) -> Void

open class CWSEmitter {
    private var mEvents: [(string: String, completion: CompletionHandler)] = []
    
    public func on(event: String, completion: @escaping CompletionHandler) {
        if let index = self.mEvents.index(where: { $0.0 == event }) {
            self.mEvents.remove(at: index)
        }
        mEvents.append((string: event, completion: completion))
    }
    
    public func emit(event: String, data: Any) {
        if let index = self.mEvents.index(where: { $0.0 == event }) {
            self.mEvents[index].completion(data)
        }
    }
    
    public func removeAllEvents() {
        self.mEvents.removeAll()
    }
}
