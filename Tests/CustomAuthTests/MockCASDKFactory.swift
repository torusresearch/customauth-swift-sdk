//
//  File.swift
//
//
//  Created by Shubham on 31/7/21.
//

import CustomAuth
import FetchNodeDetails
import Foundation
import OSLog
import TorusUtils

public class MockFactory: CASDKFactoryProtocol {
    init() {}

    public func createTorusUtils(nodePubKeys: Array<TorusNodePubModel>, loglevel: OSLogType, urlSession: URLSession,enableOneKey:Bool,network:EthereumNetworkFND) -> AbstractTorusUtils {
        MockTorusUtils()
    }

    public func createFetchNodeDetails(network: EthereumNetworkFND, urlSession: URLSession) -> FetchNodeDetails {
        let net = network == .MAINNET ? "0xf20336e16B5182637f09821c27BDe29b0AFcfe80" : "0x6258c9d6c12ed3edda59a1a6527e469517744aa7"
        return FetchNodeDetails(proxyAddress: net, network: network)
    }
}
