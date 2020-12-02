////
////  File.swift
////  
////
////  Created by Shubham on 18/11/20.
////
//
//import Foundation
//
//public struct SignerResponse: Encodable {
//    public var nonce: String
//    public var timestamp: String
//    public var timestamp: String
//    
//    enum CodingKeys: String, CodingKey {
//        case nonce
//        case signature
//        case timestamp
//    }
//    
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(nonce, forKey: .nonce)
////        try container.encode(signature, forKey: .signature)
//        try container.encode(timestamp, forKey: .timestamp)
//    }
//    
//    public init(nonce: String, signature: String, timestamp: String){
//        self.nonce = nonce
//        self.signature = signature
//        self.timestamp = timestamp
//    }
//    
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: JSONRPCresponseKeys.self)
//        let nonce: Int = try container.decode(String.self, forKey: .nonce)
//        let signature: Int = try container.decode(String.self, forKey: .signature)
//        let timestamp: Int = try container.decode(String.self, forKey: .timestamp)
//        self.init(nonce, signature, timestamp)
//    }
//}
