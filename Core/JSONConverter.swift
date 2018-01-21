//
//  JSONConverter.swift
//  ClusterWSTests
//
//  Created by Roman Baitaliuk on 21/01/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import Foundation

open class JSONConverter {
    open func convertToJSON(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch let error {
                debugPrint("JSON string conversion error: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    open func JSONStringify(value: Any, prettyPrinted: Bool? = nil) -> String? {
        let options = prettyPrinted ?? false ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
        
        if JSONSerialization.isValidJSONObject(value) {
            do {
                let data = try JSONSerialization.data(withJSONObject: value, options: options)
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            } catch let error {
                debugPrint("JSON stringify error: \(error.localizedDescription)")
            }
        }
        return nil
    }
}
