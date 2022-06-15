//
//  File.swift
//  
//
//  Created by Dhruv Jaiswal on 15/06/22.
//

import Foundation
import FetchNodeDetails

extension EthereumNetworkFND{
   public var signerMap:String{
    switch self {
    case .MAINNET:
        return "https://signer.tor.us"
    case .ROPSTEN:
        return "https://signer.tor.us"
    case .POLYGON:
        return "https://signer-polygon.tor.us"
    case .CUSTOM(let path):
        return "https://signer.tor.us"
    }
}
}
