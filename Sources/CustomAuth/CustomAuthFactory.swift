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
    func createTorusUtils(nodePubKeys: Array<TorusNodePubModel>, loglevel: OSLogType, urlSession: URLSession,enableOneKey:Bool) -> AbstractTorusUtils
    func createFetchNodeDetails(network: EthereumNetworkFND, urlSession: URLSession) -> FetchNodeDetails
}

public class CASDKFactory: CASDKFactoryProtocol {
    public func createFetchNodeDetails(network: EthereumNetworkFND, urlSession: URLSession = URLSession.shared) -> FetchNodeDetails {
        let net = network == .MAINNET ? "0xf20336e16B5182637f09821c27BDe29b0AFcfe80" : "0x6258c9d6c12ed3edda59a1a6527e469517744aa7"
        return FetchNodeDetails(proxyAddress: net, network: network, urlSession: urlSession)
    }

    public func createTorusUtils(nodePubKeys: Array<TorusNodePubModel> = [], loglevel: OSLogType, urlSession: URLSession = URLSession.shared,enableOneKey:Bool) -> AbstractTorusUtils {
        return TorusUtils(nodePubKeys: nodePubKeys, loglevel: loglevel, urlSession: urlSession,enableOneKey: enableOneKey)
    }

    public init() {
    }
}
