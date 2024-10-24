import Foundation

public class LoginWindowResponse: Codable {
    public let accessToken: String?
    public let idToken: String?
    public let ref: String
    public let extraParams: String?
    public let extraParamsPassed: String?
    public let state: TorusGenericContainer

    public init(accessToken: String? = nil, idToken: String? = nil, ref: String, extraParams: String? = nil, extraParamsPassed: String? = nil, state: TorusGenericContainer) {
        self.accessToken = accessToken
        self.idToken = idToken
        self.ref = ref
        self.extraParams = extraParams
        self.extraParamsPassed = extraParamsPassed
        self.state = state
    }
}
