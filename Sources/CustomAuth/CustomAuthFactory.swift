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
    func createTorusUtils(loglevel: OSLogType, urlSession: URLSession, enableOneKey: Bool, network: EthereumNetworkFND) -> AbstractTorusUtils
    func createFetchNodeDetails(network: EthereumNetworkFND, urlSession: URLSession, networkUrl: String?) -> FetchNodeDetails
}

public class CASDKFactory: CASDKFactoryProtocol {
    public func createFetchNodeDetails(network: EthereumNetworkFND, urlSession: URLSession = URLSession.shared, networkUrl: String? = nil) -> FetchNodeDetails {
        var proxyAddress: String = ""
        switch network {
        case .MAINNET:
            proxyAddress = FetchNodeDetails.proxyAddressMainnet
        case .TESTNET:
            proxyAddress = FetchNodeDetails.proxyAddressTestnet
        case .CYAN:
            proxyAddress = FetchNodeDetails.proxyAddressCyan
        case .AQUA:
            proxyAddress = FetchNodeDetails.proxyAddressAqua
        case .CELESTE:
            proxyAddress = FetchNodeDetails.proxyAddressCeleste
        default:
            proxyAddress = FetchNodeDetails.proxyAddressMainnet
        }
        guard let networkUrl = networkUrl else { return FetchNodeDetails(proxyAddress: proxyAddress, network: network, urlSession: urlSession) }
        return FetchNodeDetails(proxyAddress: proxyAddress, network: .CUSTOM(path: networkUrl),urlSession: urlSession)
    }

    public func createTorusUtils(loglevel: OSLogType, urlSession: URLSession = URLSession.shared, enableOneKey: Bool, network: EthereumNetworkFND) -> AbstractTorusUtils {
        let allowHost = network.signerMap.appending("/api/allow")
        let signerHost = network.signerMap.appending("/api/sign")
        return TorusUtils(loglevel: loglevel, urlSession: urlSession, enableOneKey: enableOneKey, signerHost: signerHost, allowHost: allowHost, network: network)
    }

    public init() {
    }
}
