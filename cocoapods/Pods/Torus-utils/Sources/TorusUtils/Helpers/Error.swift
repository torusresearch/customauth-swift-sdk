//
//  File.swift
//  
//
//  Created by Shubham on 2/4/20.
//

import Foundation

public enum TorusError: Error{
    case apiRequestFailed
    case errInResponse(Any)
    case decodingError
    case commitmentRequestFailed
    case decryptionFailed
}

extension TorusError: CustomDebugStringConvertible{
    public var debugDescription: String{
        switch self {
        case .apiRequestFailed:
            return "API request failed or No response from the node"
        case .decodingError:
            return "JSON Decoding error"
        case .errInResponse(let str):
            return "API response error \(str)"
        case .decryptionFailed:
            return "Decryption Failed"
        case .commitmentRequestFailed:
            return "commitment request failed"
        }
        
    }
}
