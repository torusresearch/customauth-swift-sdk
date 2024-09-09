import Foundation

public class SubVerifierDetails: Codable {
    public let typeOfLogin: LoginType
    public let verifier: String
    public let clientId: String
    public let redirectURL: String
    public let jwtParams: Auth0ClientOptions?
    public let hash: String?
    public let queryParams: TorusGenericContainer?
    public let customState: TorusGenericContainer?

    public init(typeOfLogin: LoginType, verifier: String, clientId: String, redirectURL: String = "https://scripts.toruswallet.io/redirect.html", jwtParams: Auth0ClientOptions? = nil, hash: String? = nil, queryParams: TorusGenericContainer? = nil, customState: TorusGenericContainer? = nil) {
        self.typeOfLogin = typeOfLogin
        self.verifier = verifier
        self.clientId = clientId
        self.jwtParams = jwtParams
        self.hash = hash
        self.queryParams = queryParams
        self.customState = customState
        self.redirectURL = redirectURL
    }
}

public typealias SingleLoginParams = SubVerifierDetails
