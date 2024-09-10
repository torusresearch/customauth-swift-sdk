import Foundation
import FetchNodeDetails

internal class CreateHandlerParams {
    public let typeOfLogin: LoginType
    public let verifier: String
    public let clientId: String
    public let urlScheme: String
    public let redirectURL: String
    public let jwtParams: Auth0ClientOptions?
    public let customState: TorusGenericContainer?
    public let web3AuthNetwork: TorusNetwork
    public let web3AuthClientId: String

    public init(typeOfLogin: LoginType, verifier: String, clientId: String, urlScheme: String, redirectURL: String, jwtParams: Auth0ClientOptions? = nil, customState: TorusGenericContainer? = nil, web3AuthNetwork: TorusNetwork, web3AuthClientId: String) {
        self.typeOfLogin = typeOfLogin
        self.verifier = verifier
        self.clientId = clientId
        self.urlScheme = urlScheme
        self.jwtParams = jwtParams
        self.customState = customState
        self.redirectURL = redirectURL
        self.web3AuthNetwork = web3AuthNetwork
        self.web3AuthClientId = web3AuthClientId
    }
}
