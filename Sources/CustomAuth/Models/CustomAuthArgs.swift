import FetchNodeDetails
import Foundation

public struct CustomAuthArgs: Codable {
    var network: String
    var redirectUri: String
    var browserRedirectUri: String? = "https://scripts.toruswallet.io/redirect.html"
    var enableLogging: Bool? = true
    var enableOneKey: Bool? = false
    var networkUrl: String?

    init(network: String, redirectUri: String) {
        self.network = network
        self.redirectUri = redirectUri
    }

    var nativeNetwork: EthereumNetworkFND {
        if network == "testnet" {
            return .TESTNET
        } else if network == "cyan" {
            return .CYAN
        } else if network == "celeste" {
            return .CELESTE
        } else if network == "aqua" {
            return .AQUA
        } else {
            return .MAINNET
        }
    }
}