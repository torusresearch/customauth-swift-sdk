import Foundation

internal class FacebookPictureData: Codable {
    public var url: String
}

internal class FacebookPicture: Codable {
    public var data: FacebookPictureData
}

internal class FacebookInfo: Codable {
    public var id: String
    public var name: String
    public var picture: FacebookPicture
    public var email: String
}

internal class FacebookLoginHandler: AbstractLoginHandler {
    private var response_type: String = "token"
    private var scope: String = "public_profile email"

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

        return TorusVerifierResponse(email: result.email, name: result.name, profileImage: result.picture.data.url, verifier: self.params.verifier, verifierId: result.id, typeOfLogin: self.params.typeOfLogin)
    }
}
