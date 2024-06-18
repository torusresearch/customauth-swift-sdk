import Foundation

class FacebookInfo: Codable {
    public var id: String
    public var username: String
    public var profileImage: String
    public var email: String
}

class FacebookLoginHandler: AbstractLoginHandler {
    private var response_type: String = "token"
    private var scope: String = "public_profile email"

    override public init(clientId: String, verifier: String, urlScheme: String, redirectURL: String, typeOfLogin: LoginType, jwtParams: Auth0ClientOptions? = nil, customState: TorusGenericContainer? = nil) throws {
        try super.init(clientId: clientId, verifier: verifier, urlScheme: urlScheme, redirectURL: redirectURL, typeOfLogin: typeOfLogin, jwtParams: jwtParams, customState: customState)
        try setFinalUrl()
    }

    override public func setFinalUrl() throws {
        var urlComponents = URLComponents()

        var params: [String: String] = [:]

        if jwtParams != nil {
            params = try (JSONSerialization.jsonObject(with: try JSONEncoder().encode(jwtParams), options: []) as! [String: String])
        }

        params.merge([
            "state": try state(),
            "response_type": response_type,
            "client_id": clientId,
            "redirect_uri": redirectURL,
            "scope": scope], uniquingKeysWith: { _, new in new })
        urlComponents.scheme = "https"
        urlComponents.host = "www.facebook.com"
        urlComponents.path = "/v15.0/dialog/oauth"
        urlComponents.setQueryItems(with: params)

        finalUrl = urlComponents
    }

    override public func getUserInfo(params: LoginWindowResponse, storageServerUrl: String?) async throws -> TorusVerifierResponse {
        guard let accessToken = params.accessToken else {
            throw CASDKError.accessTokenNotProvided
        }

        var urlRequest = makeUrlRequest(url: "https://graph.facebook.com/me?fields=name,email,picture.type(large)", method: "GET")
        urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: urlRequest)

        let result = try JSONDecoder().decode(FacebookInfo.self, from: data)

        return TorusVerifierResponse(email: result.email, name: result.username, profileImage: result.profileImage, verifier: verifier, verifierId: result.id, typeOfLogin: typeOfLogin)
    }
}
