import Foundation

internal class RedditInfo: Codable {
    public var name: String
    public var icon_image: String?
}

internal class RedditLoginHandler: AbstractLoginHandler {
    private var response_type: String = "token"
    private var scope: String = "identity"

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
        ], uniquingKeysWith: { _, new in new })
        urlComponents.scheme = "https"
        urlComponents.host = "www.reddit.com"
        urlComponents.path = "/api/v1/authorize"
        urlComponents.setQueryItems(with: params)

        finalUrl = urlComponents
    }

    override public func getUserInfo(params: LoginWindowResponse, storageServerUrl: String?) async throws -> TorusVerifierResponse {
        guard let accessToken = params.accessToken else {
            throw CASDKError.accessTokenNotProvided
        }

        var urlRequest = makeUrlRequest(url: "https://oauth.reddit.com/api/v1/me", method: "GET")
        urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: urlRequest)

        let result = try JSONDecoder().decode(RedditInfo.self, from: data)

        var profileImage = result.icon_image ?? ""
        profileImage = profileImage.split(separator: "?").count > 0 ? String(profileImage.split(separator: "?")[0]) : profileImage

        return TorusVerifierResponse(email: "", name: result.name, profileImage: profileImage, verifier: verifier, verifierId: result.name.lowercased(), typeOfLogin: typeOfLogin)
    }
}
