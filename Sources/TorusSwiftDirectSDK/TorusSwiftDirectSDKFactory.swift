//
//  File.swift
//  
//
//  Created by Shubham on 30/7/21.
//

import Foundation
import TorusUtils
import FetchNodeDetails
import OSLog
import BestLogger

public protocol TDSDKFactoryProtocol{
    func createTorusUtils(level: OSLogType, nodePubKeys: Array<TorusNodePub>) -> AbstractTorusUtils
    func createFetchNodeDetails(network: EthereumNetwork) -> FetchNodeDetails
}


public class TDSDKFactory: TDSDKFactoryProtocol{
    public func createFetchNodeDetails(network: EthereumNetwork) -> FetchNodeDetails {
        let net = network == .MAINNET ? "0x638646503746d5456209e33a2ff5e3226d698bea" : "0x4023d2a0D330bF11426B12C6144Cfb96B7fa6183"
        return FetchNodeDetails(proxyAddress: net, network: network)
    }
    
    public func createTorusUtils(level: OSLogType, nodePubKeys: Array<TorusNodePub> = []) -> AbstractTorusUtils {
        // TODO(michaellee8): remove the conversion here after TorusUtils migrated to OSLog
        var blLevel = BestLogger.Level.none
        switch level {
        case .debug:
            blLevel = .debug
        case .info:
            blLevel = .info
        case .error:
            blLevel = .error
        case .fault:
            blLevel = .error
        case .default:
            blLevel = .debug
        default:
            blLevel = .none
        }
        return TorusUtils(label: "TorusUtils", loglevel: blLevel, nodePubKeys: nodePubKeys)
    }
}
