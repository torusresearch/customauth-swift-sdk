//
//  nodeInfo.swift
//  
//
//  Created by Shubham on 13/3/20.
//

import Foundation
import web3
import BigInt

public struct NodeDetails: ABITuple {
    public var encodableValues: [ABIType] {[declaredIp, position, pubKx, pubKy, tmP2PListenAddress, p2pListenAddress]}
    public static var types: [ABIType.Type] { [String.self, BigInt.self, BigInt.self, BigInt.self, String.self, String.self] }
    
    var declaredIp: String;
    var position: BigInt;
    var pubKx: BigInt;
    var pubKy: BigInt;
    var tmP2PListenAddress: String;
    var p2pListenAddress: String;

    init( declaredIp: String,
          position: BigInt,
          pubKx: BigInt,
          pubKy: BigInt,
          tmP2PListenAddress: String,
          p2pListenAddress: String) {
        self.declaredIp = declaredIp
        self.position = position
        self.pubKx = pubKx
        self.pubKy = pubKy
        self.tmP2PListenAddress = tmP2PListenAddress
        self.p2pListenAddress = p2pListenAddress
    }
    
    public init?(values: [ABIDecoder.DecodedValue]) throws {
        self.declaredIp = try values[0].decoded()
        self.position = try values[1].decoded()
        self.pubKx = try values[2].decoded()
        self.pubKy = try values[3].decoded()
        self.tmP2PListenAddress = try values[4].decoded()
        self.p2pListenAddress = try values[5].decoded()
    }
    
    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(declaredIp)
        try encoder.encode(position)
        try encoder.encode(pubKx)
        try encoder.encode(pubKy)
        try encoder.encode(tmP2PListenAddress)
        try encoder.encode(p2pListenAddress)
    }
    
    public func getDeclaredIp() -> String {
        return declaredIp;
    }
    
    public func getP2pListenAddress() -> String {
        return p2pListenAddress;
    }
    
    public func getPosition() -> BigInt {
        return position;
    }
    
    public func getPubKx() -> BigInt {
        return pubKx;
    }
    
    public func getPubKy() -> BigInt {
        return pubKy;
    }
    
    public func getTmP2PListenAddress() -> String {
        return tmP2PListenAddress;
    }
}
//
//public class NodeInfo {
//    private var declaredIp: String;
//    private var position: String;
//    private var pubKx: String;
//    private var pubKy: String;
//    private var tmP2PListenAddress: String;
//    private var p2pListenAddress: String;
//
//    public init(_declaredIp : String, _position : String, _pubKx : String, _pubKy : String, _tmP2PListenAddress : String, _p2pListenAddress : String) {
//        self.declaredIp = _declaredIp;
//        self.position = _position;
//        self.pubKx = _pubKx;
//        self.pubKy = _pubKy;
//        self.tmP2PListenAddress = _tmP2PListenAddress;
//        self.p2pListenAddress = _p2pListenAddress;
//    }
//
//    public func getDeclaredIp() -> String {
//        return declaredIp;
//    }
//
//    public func getP2pListenAddress() -> String {
//        return p2pListenAddress;
//    }
//
//    public func getPosition() -> String {
//        return position;
//    }
//
//    public func getPubKx() -> String {
//        return pubKx;
//    }
//
//    public func getPubKy() -> String {
//        return pubKy;
//    }
//
//    public func getTmP2PListenAddress() -> String {
//        return tmP2PListenAddress;
//    }
//}
