//
//  NodeListContract.swift.swift
//  
//
//  Created by Shubham on 27/7/21.
//

import Foundation
import web3
import BigInt


public enum NodeListProxyContract{
        
    public struct CurrentEpoch: ABIFunction {
        public static var name: String = "currentEpoch"
        
        public var gasPrice: BigUInt? = nil
        
        public var gasLimit: BigUInt? = nil
        
        public var contract: EthereumAddress
        
        public var from: EthereumAddress?
        
        public init(contract: EthereumAddress) {
            self.contract = contract
        }
        
        public func encode(to encoder: ABIFunctionEncoder) throws {
            
        }
        
    }
    
    public struct getEpochInfo: ABIFunction {
        public static var name: String = "getEpochInfo"
        
        public var gasPrice: BigUInt?
        
        public var gasLimit: BigUInt?
        
        public var contract: EthereumAddress
        
        public var from: EthereumAddress?
        
        public var epoch: BigInt
        
        public init(contract: EthereumAddress, epoch: BigInt) {
            self.contract = contract
            self.epoch = epoch
        }
        
        public func encode(to encoder: ABIFunctionEncoder) throws {
            try encoder.encode(BigUInt(epoch))
        }
    }
    
    public struct getNodeDetails: ABIFunction {
        public static var name: String = "getNodeDetails"
        
        public var gasPrice: BigUInt?
        
        public var gasLimit: BigUInt?
        
        public var contract: EthereumAddress
        
        public var from: EthereumAddress?
        
        public var address: EthereumAddress
        
        public init(contract: EthereumAddress, address: EthereumAddress) {
            self.contract = contract
            self.address = address
        }
        
        public func encode(to encoder: ABIFunctionEncoder) throws {
            try encoder.encode(address)
        }
    }
}

enum FNDError: Error{
    case currentEpochFailed
    case epochInfoFailed
    case nodeDetailsFailed
    case allNodeDetailsFailed
}

extension FNDError: CustomDebugStringConvertible{
    public var debugDescription: String{
        switch self{
            case .currentEpochFailed:
                return "current epoch failed"
            case .epochInfoFailed:
                return "epoch info failed"
            case .nodeDetailsFailed:
                return "node details failed"
            case .allNodeDetailsFailed:
                return "unable to get node details for all nodes"
        }
    }
}
