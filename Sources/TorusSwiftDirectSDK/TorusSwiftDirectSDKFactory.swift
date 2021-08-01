//
//  File.swift
//  
//
//  Created by Shubham on 30/7/21.
//

import Foundation
import TorusUtils
import FetchNodeDetails
import BestLogger

public protocol TorusDirectSwiftSDKFactory{
    func createTorusUtils(level: BestLogger.Level, nodePubKeys: Array<TorusNodePub>) -> AbstractTorusUtils
    func createFetchNodeDetails(network: EthereumNetwork) -> FetchNodeDetails
    func createLogger(label: String, level: BestLogger.Level) -> BestLogger
}


public class FactoryCreator: TorusDirectSwiftSDKFactory{
    public func createFetchNodeDetails(network: EthereumNetwork) -> FetchNodeDetails {
        let net = network == .MAINNET ? "0x638646503746d5456209e33a2ff5e3226d698bea" : "0x4023d2a0D330bF11426B12C6144Cfb96B7fa6183"
        return FetchNodeDetails(proxyAddress: net, network: network)
    }
    
    public func createLogger(label: String, level: BestLogger.Level) -> BestLogger {
        return BestLogger(label: label, level: level)
    }
    
    public func createTorusUtils(level: BestLogger.Level, nodePubKeys: Array<TorusNodePub> = []) -> AbstractTorusUtils {
        return TorusUtils(label: "TorusUtils", loglevel: level, nodePubKeys: nodePubKeys) as! AbstractTorusUtils
    }
}
