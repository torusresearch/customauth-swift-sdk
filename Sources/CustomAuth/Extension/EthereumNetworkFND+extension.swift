//
//  File.swift
//
//
//  Created by Dhruv Jaiswal on 15/06/22.
//

import FetchNodeDetails
import Foundation
import CommonSources

extension TorusNetwork {
    public var signerMap: String {
        switch self {
        case .legacy(let network) :
            switch network {
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
                return path
            }
        case .sapphire(let network) :
            switch network {
                
            case .SAPPHIRE_MAINNET:
                return "https://signer.tor.us"
            case .SAPPHIRE_DEVNET:
                return "https://signer.tor.us"
                
            }
        }
    }
}
