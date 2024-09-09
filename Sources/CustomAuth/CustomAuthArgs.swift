import FetchNodeDetails
import Foundation

public class CustomAuthArgs {
    public let urlScheme: String
    public let metadataUrl: String
    public let network: TorusNetwork
    public let enableLogging: Bool
    public let enableOneKey: Bool
    public let apiKey: String
    public let popupFeatures: String?
    public let storageServerUrl: String
    public let web3AuthClientId: String
    public let serverTimeOffset: Int
    public let useDkg: Bool // TODO: Implement usage of this

    public init(urlScheme: String,
                network: TorusNetwork,
                metadataUrl: String = "https://metadata.tor.us",
                enableLogging: Bool = false,
                apiKey: String = "torus-default",
                storageServerUrl: String = "https://session.web3auth.io",
                enableOneKey: Bool = false,
                web3AuthClientId: String,
                useDkg: Bool = true,
                serverTimeOffset: Int = 0,
                popupFeatures: String? = nil
    ) {
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
        self.useDkg = useDkg
    }
}
