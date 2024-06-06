import Foundation

class TwitchInfo: Codable {
    public var id: String
    public var display_name: String
    public var profile_image_url: String
}

class TwitchRootInfo: Codable {
    public var data: TwitchInfo
}

class TwitchLoginHandler: AbstractLoginHandler {
    private var response_type: String = "token"
    private var scope: String = "user:read:email"

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
            "scope": scope,
            "force_verify": "true",
        ], uniquingKeysWith: { _, new in new })
        urlComponents.scheme = "https"
        urlComponents.host = "id.twitch.tv"
        urlComponents.path = "/oauth2/authorize"
        urlComponents.setQueryItems(with: params)

        finalUrl = urlComponents
    }

    override public func getUserInfo(params: LoginWindowResponse, storageServerUrl: String?) async throws -> TorusVerifierResponse {
        guard let accessToken = params.accessToken else {
            throw CASDKError.accessTokenNotProvided
        }

        var urlRequest = makeUrlRequest(url: "https://api.twitch.tv/helix/users", method: "GET")
        urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: urlRequest)

        let result = try JSONDecoder().decode(TwitchRootInfo.self, from: data)

        return TorusVerifierResponse(email: "", name: result.data.display_name, profileImage: result.data.profile_image_url, verifier: verifier, verifierId: result.data.id, typeOfLogin: typeOfLogin)
    }
}
