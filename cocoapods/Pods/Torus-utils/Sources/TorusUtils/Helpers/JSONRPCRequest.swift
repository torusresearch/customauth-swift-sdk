//
//  JSONRPCRequest.swift
//  
//
//  Created by Shubham on 26/3/20.
//

import Foundation
import BigInt

/// JSON RPC request structure for serialization and deserialization purposes.
public struct JSONRPCrequest: Encodable {
    public var jsonrpc: String = "2.0"
    public var method: String
    public var params: Any
    public var id: Int = Int.random(in: 0 ... 10)
    
    enum CodingKeys: String, CodingKey {
        case jsonrpc
        case method
        case params
        case id
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(jsonrpc, forKey: .jsonrpc)
        try container.encode(method, forKey: .method)
        
        if let newParams = params as? [String:String] {
            try container.encode(params as! [String:String], forKey: .params)
        }
        if let newParams = params as? [String: [String:[String:String]]] {
            try container.encode(params as! [String: [String:[String:String]]], forKey: .params)
        }
        
        try container.encode(id, forKey: .id)
    }
}

public struct JSONRPCresponse: Codable{
    public var id: Int
    public var jsonrpc = "2.0"
    public var result: Any
    public var error: ErrorMessage?
    public var message: String?
    
    enum JSONRPCresponseKeys: String, CodingKey {
        case id = "id"
        case jsonrpc = "jsonrpc"
        case result = "result"
        case error = "error"
        case errorMessage
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: JSONRPCresponseKeys.self)
        try? container.encode(result as? [String: [[String: String]]], forKey: .result)
        try? container.encode(result as? [String: String], forKey: .result)
        try container.encode(error, forKey: .error)
    }
    
    public init(id: Int, jsonrpc: String, result: Any?, error: ErrorMessage?) {
        self.id = id
        self.jsonrpc = jsonrpc
        self.result = result
        self.error = error
    }
    
//    public struct ErrorMessage: Decodable {
//        public var code: Int
//        public var message: String
//    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONRPCresponseKeys.self)
        let id: Int = try container.decode(Int.self, forKey: .id)
        let jsonrpc: String = try container.decode(String.self, forKey: .jsonrpc)
        let errorMessage = try container.decodeIfPresent(ErrorMessage.self, forKey: .error)
        if errorMessage != nil {
            self.init(id: id, jsonrpc: jsonrpc, result: nil, error: errorMessage)
            return
        }
        var result: Any? = nil
        if let rawValue = try? container.decodeIfPresent(String.self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent(Int.self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent(Bool.self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([Bool].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([Int].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([String].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([String: String].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([String: [[String: String]]].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([String: Int].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([String:[String:[String:String]]].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([String:[String:[String:[String:String?]]]].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([String: Any].self, forKey: .result) {
            result = rawValue
        }
        // print("result is", result)
        self.init(id: id, jsonrpc: jsonrpc, result: result, error: nil)
    }
}

public struct ErrorMessage: Codable {
    public var code: Int
    public var message: String
    
    
    enum ErrorMessageKeys: String, CodingKey {
        case code
        case message
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ErrorMessageKeys.self)
        try container.encode(message, forKey: .message)
        try container.encode(code, forKey: .code)
    }
}



