import Foundation

public class UserInfo: Codable {
    public let email: String
    public let name: String
    public let profileImage: String
    public let aggregateVerifier: String?
    public let verifier: String
    public let verifierId: String
    public let typeOfLogin: LoginType
    public let ref: String?
    public let extraVerifierParams: PassKeyExtraParams?
    public let accessToken: String?
    public let idToken: String?
    public let extraParams: String?
    public let extraParamsPassed: String?
    public let state: TorusGenericContainer

    public init(email: String, name: String, profileImage: String, aggregateVerifier: String? = nil, verifier: String, verifierId: String, typeOfLogin: LoginType, ref: String? = nil, extraVerifierParams: PassKeyExtraParams? = nil, accessToken: String? = nil, idToken: String? = nil, extraParams: String? = nil, extraParamsPassed: String? = nil, state: TorusGenericContainer) {
        self.email = email
        self.name = name
        self.profileImage = profileImage
        self.aggregateVerifier = aggregateVerifier
        self.verifier = verifier
        self.verifierId = verifierId
        self.typeOfLogin = typeOfLogin
        self.ref = ref
        self.extraVerifierParams = extraVerifierParams
        self.accessToken = accessToken
        self.idToken = idToken
        self.extraParams = extraParams
        self.extraParamsPassed = extraParamsPassed
        self.state = state
    }
}
