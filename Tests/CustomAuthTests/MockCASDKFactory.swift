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
import CommonSources
public class MockFactory: CASDKFactoryProtocol {
    init() {}

    public func createTorusUtils(loglevel: OSLogType, urlSession: URLSession, enableOneKey: Bool, network: TorusNetwork) -> AbstractTorusUtils {
        MockTorusUtils()
    }

//    public func createFetchNodeDetails(network: TorusNetwork, urlSession: URLSession, networkUrl: String? = nil) -> AllNodeDetailsModel {
//        let net = network == .MAINNET ? "0xf20336e16B5182637f09821c27BDe29b0AFcfe80" : "0x6258c9d6c12ed3edda59a1a6527e469517744aa7"
//        return AllNodeDetailsModel(proxyAddress: net, network: network)
//    }
}
