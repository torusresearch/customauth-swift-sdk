//
//  epochInfo.swift
//  
//
//  Created by Shubham on 13/3/20.
//

import Foundation
import web3
import BigInt

public struct EpochInfo: ABITuple {
    
    public static var types: [ABIType.Type] { [BigInt.self, BigInt.self, BigInt.self, BigInt.self, ABIArray<EthereumAddress>.self, BigInt.self, BigInt.self] }
    
    var id: BigInt
    var n: BigInt
    var k: BigInt
    var t: BigInt
    var nodeList: [EthereumAddress]
    var prevEpoch: BigInt
    var nextEpoch: BigInt
    
    init(id: BigInt,
         n: BigInt,
         k: BigInt,
         t: BigInt,
         nodeList: [EthereumAddress],
         prevEpoch: BigInt,
         nextEpoch: BigInt) {
        self.id =  id
        self.n = n
        self.k = k
        self.t = t
        self.nodeList = nodeList
        self.prevEpoch = prevEpoch
        self.nextEpoch = nextEpoch
    }
    
    public init?(values: [ABIDecoder.DecodedValue]) throws {
        self.nodeList = try values.dropLast(2).dropFirst(4).map{try $0.decoded() }
        
        self.id = try values[0].decoded()
        self.n = try values[1].decoded()
        self.k = try values[2].decoded()
        self.t = try values[3].decoded()
        self.prevEpoch = try values[values.count-2].decoded()
        self.nextEpoch = try values[values.count-1].decoded()
        
    }
    
    public func encode(to encoder: ABIFunctionEncoder) throws {
        try encoder.encode(id)
        try encoder.encode(n)
        try encoder.encode(k)
        try encoder.encode(t)
        try encoder.encode(nodeList)
        try encoder.encode(prevEpoch)
        try encoder.encode(nextEpoch)
    }
    
    public var encodableValues: [ABIType] { [id, n, k, t, ABIArray(values: nodeList), prevEpoch, nextEpoch] }
    
    public func getId() -> BigInt {
        return self.id;
    }

    public func getK() -> BigInt{
        return self.k;
    }

    public func getN() -> BigInt{
        return self.n;
    }

    public func getNextEpoch() -> BigInt{
        return self.nextEpoch;
    }

    public func getPrevEpoch() -> BigInt{
        return self.prevEpoch;
    }

    public func getT() -> BigInt{
        return self.t;
    }

    public func getNodeList() -> [EthereumAddress] {
        return self.nodeList;
    }
}
