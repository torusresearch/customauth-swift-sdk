import Foundation

internal class GoogleInfo: Codable {
    public var name: String
    public var picture: String
    public var email: String
}

internal class GoogleLoginHandler: AbstractLoginHandler {
    private var response_type: String = "token id_token"
    private var scope: String = "profile email openid"
    private var prompt: String = "select_account"

    override public init(params: CreateHandlerParams) throws {
        try super.init(params: params)
        try setFinalUrl()
    }

    override public func setFinalUrl() throws {
        var urlComponents = URLComponents()

        var params: [String: String] = [:]

        if self.params.jwtParams != nil {
            params = try (JSONSerialization.jsonObject(with: try JSONEncoder().encode(self.params.jwtParams), options: []) as! [String: String])
        }

        params.merge([
            "state": try state(),
            "response_type": response_type,
            "client_id": self.params.clientId,
            "prompt": prompt,
            "redirect_uri": self.params.redirectURL,
            "scope": scope,
            "nonce": nonce,
        ], uniquingKeysWith: { _, new in new })
        urlComponents.scheme = "https"
        urlComponents.host = "accounts.google.com"
        urlComponents.path = "/o/oauth2/v2/auth"
        urlComponents.setQueryItems(with: params)

        finalUrl = urlComponents
    }

    override public func getUserInfo(params: LoginWindowResponse, storageServerUrl: String?) async throws -> TorusVerifierResponse {
        guard let accessToken = params.accessToken else {
            throw CASDKError.accessTokenNotProvided
        }

        var urlRequest = makeUrlRequest(url: "https://www.googleapis.com/userinfo/v2/me", method: "GET")
        urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: urlRequest)

        let result = try JSONDecoder().decode(GoogleInfo.self, from: data)

        return TorusVerifierResponse(email: result.email, name: result.name, profileImage: result.picture, verifier: self.params.verifier, verifierId: result.email.lowercased(), typeOfLogin: self.params.typeOfLogin)
    }
}
