import FetchNodeDetails
import Foundation

public class CustomAuthArgs {
    public let urlScheme: String
    public let metadataUrl: String?
    public let network: TorusNetwork
    public let enableLogging: Bool
    public let enableOneKey: Bool
    public let apiKey: String?
    public let popupFeatures: String?
    public let storageServerUrl: String?
    public let web3AuthClientId: String
    public let serverTimeOffset: Int

    public init(urlScheme: String, metadataUrl: String? = nil, network: TorusNetwork, enableLogging: Bool = false, enableOneKey: Bool, apiKey: String? = nil, popupFeatures: String? = nil, storageServerUrl: String? = nil, web3AuthClientId: String, serverTimeOffset: Int = 0, legacyMetadataHost: String? = nil) {
        self.urlScheme = urlScheme
        self.metadataUrl = metadataUrl
        self.network = network
        self.enableLogging = enableLogging
        self.enableOneKey = enableOneKey
        self.apiKey = apiKey
        self.popupFeatures = popupFeatures
        self.storageServerUrl = storageServerUrl
        self.web3AuthClientId = web3AuthClientId
        self.serverTimeOffset = serverTimeOffset
    }
}
