//
//  File.swift
//
//
//  Created by Dhruv Jaiswal on 15/06/22.
//

import FetchNodeDetails
import Foundation

extension EthereumNetworkFND {
    public var signerMap: String {
        switch self {
        case .MAINNET:
            return "https://signer.tor.us"
        case .TESTNET:
            return "https://signer.tor.us"
        case .CYAN:
            return "https://signer-polygon.tor.us"
        case .AQUA:
            return "https://signer-polygon.tor.us"
        case .CELESTE:
            return "https://signer-polygon.tor.us"
        case let .CUSTOM(path):
            return "https://signer.tor.us"
        }
    }
}
