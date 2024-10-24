import Foundation

internal class TwitchInfo: Codable {
    public var id: String
    public var email: String?
    public var display_name: String
    public var profile_image_url: String
}

internal class TwitchRootInfo: Codable {
    public var data: [TwitchInfo]
}

internal class TwitchLoginHandler: AbstractLoginHandler {
    private var response_type: String = "token"
    private var scope: String = "user:read:email"

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
            "redirect_uri": self.params.redirectURL,
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
        urlRequest.addValue(self.params.clientId, forHTTPHeaderField: "Client-ID")
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        let result = try JSONDecoder().decode(TwitchRootInfo.self, from: data)
        
        guard let userdata = result.data.first else {
            throw CASDKError.decodingFailed
        }

        return TorusVerifierResponse(email: userdata.email ?? "", name: userdata.display_name, profileImage: userdata.profile_image_url, verifier: self.params.verifier, verifierId: userdata.id, typeOfLogin: self.params.typeOfLogin)
    }
}
