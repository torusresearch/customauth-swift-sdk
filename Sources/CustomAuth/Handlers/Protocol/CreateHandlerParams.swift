import Foundation

internal class CreateHandlerParams: Codable {
    public let typeOfLogin: LoginType
    public let verifier: String
    public let clientId: String
    public let urlScheme: String
    public let redirectURL: String
    public let jwtParams: Auth0ClientOptions?
    public let customState: TorusGenericContainer?

    public init(typeOfLogin: LoginType, verifier: String, clientId: String, urlScheme: String, redirectURL: String, jwtParams: Auth0ClientOptions? = nil, customState: TorusGenericContainer? = nil) {
        self.typeOfLogin = typeOfLogin
        self.verifier = verifier
        self.clientId = clientId
        self.urlScheme = urlScheme
        self.jwtParams = jwtParams
        self.customState = customState
        self.redirectURL = redirectURL
    }
}
