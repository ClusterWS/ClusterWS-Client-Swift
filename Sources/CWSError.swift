//
//  CWSErrors.swift
//  ClusterWSTests
//
//  Created by Roman Baitaliuk on 20/01/18.
//  Copyright © 2018 ByteKit. All rights reserved.
//

import Foundation

public enum CWSError: Error, LocalizedError {
    case invalidURL(String)
    case JSONStringConversionError(String)
    case JSONStringifyError(Any?)
    case hashArrayCastError(Any)
    case pingJSONCastError(Any)
    case pingIntervalCastError(Any)
    case binaryCastError(Any)
    case binaryDecodeError(Any)
    case binaryEncodeError(Any)
    case failedToCastPingTimer
    public var localizedDescription: String {
        switch self {
        case .invalidURL(let url): return "Invalid URL: \(url)."
        case .JSONStringConversionError(let jsonString): return "Cannot convert string to JSON, string: \(jsonString)."
        case .JSONStringifyError(let data): return "Cannot stringify JSON dictionary with 'Any' data to a string, data: \(String(describing: data))."
        case .hashArrayCastError(let hashArray): return "Cannot cast JSON with '#' key to an arrray of 'Any' objects from massage, JSON: \(hashArray)."
        case .pingJSONCastError(let array): return "Cannot cast array object to JSON with ping values, array object: \(array)."
        case .pingIntervalCastError(let json): return "Cannot cast ping interval as 'Double' from ping JSON, JSON: \(json)."
        case .binaryCastError(let json): return "Cannot cast ping binary as 'Bool' from ping JSON, JSON: \(json)."
        case .binaryDecodeError(let message): return "Cannot convert binary message to string using UTF8, message: \(message)."
        case .binaryEncodeError(let ping): return "Cannot encode ping message to binary, ping message: \(ping)."
         case .failedToCastPingTimer: return "Failed to get ping timer from settings, might be a server set up error."
        }
    }
}
