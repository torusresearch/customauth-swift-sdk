//
//  File.swift
//
//
//  Created by Shubham on 30/7/21.
//

import FetchNodeDetails
import Foundation
import OSLog
import TorusUtils

/// A protocol should be implmented by users of `CustomAuth`. It provides a way
/// to stub or mock the CustomAuth for testing.
public protocol CASDKFactoryProtocol {
    func createTorusUtils(nodePubKeys: Array<TorusNodePubModel>, loglevel: OSLogType, urlSession: URLSession,enableOneKey:Bool,network:EthereumNetworkFND) -> AbstractTorusUtils
    func createFetchNodeDetails(network: EthereumNetworkFND, urlSession: URLSession) -> FetchNodeDetails
}

public class CASDKFactory: CASDKFactoryProtocol {
    public func createFetchNodeDetails(network: EthereumNetworkFND, urlSession: URLSession = URLSession.shared) -> FetchNodeDetails {
        var proxyAddress:String = ""
         switch network {
        case .MAINNET:
           proxyAddress = FetchNodeDetails.proxyAddressMainnet
        case .ROPSTEN:
            proxyAddress = FetchNodeDetails.proxyAddressRopsten
        case .POLYGON:
            proxyAddress = FetchNodeDetails.proxyAddressPolygon
        case .CUSTOM(let path):
            return FetchNodeDetails(network: .CUSTOM(path: path))
        }
        
        return FetchNodeDetails(proxyAddress: proxyAddress, network: network, urlSession: urlSession)
    }

    public func createTorusUtils(nodePubKeys: Array<TorusNodePubModel> = [], loglevel: OSLogType, urlSession: URLSession = URLSession.shared,enableOneKey:Bool,network:EthereumNetworkFND) -> AbstractTorusUtils {
        let allowHost = network.signerMap.appending("/api/allow")
        let signerHost = network.signerMap.appending("/api/sign")
        return TorusUtils(nodePubKeys: nodePubKeys, loglevel: loglevel, urlSession: urlSession,enableOneKey: enableOneKey,signerHost: signerHost,allowHost: allowHost)
    }

    public init() {
    }
}
