import Foundation

internal class DiscordInfo: Codable {
    public var id: String
    public var username: String
    public var avatar: String?
    public var discriminator: String
    public var email: String
}

internal class DiscordLoginHandler: AbstractLoginHandler {
    private var response_type: String = "token"
    private var scope: String = "identify email"
    private var prompt: String = "none"

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
            "prompt": prompt,
            "scope": scope], uniquingKeysWith: { _, new in new })
        urlComponents.scheme = "https"
        urlComponents.host = "discord.com"
        urlComponents.path = "/api/oauth2/authorize"
        urlComponents.setQueryItems(with: params)

        finalUrl = urlComponents
    }

    override public func getUserInfo(params: LoginWindowResponse, storageServerUrl: String?) async throws -> TorusVerifierResponse {
        guard let accessToken = params.accessToken else {
            throw CASDKError.accessTokenNotProvided
        }

        var urlRequest = makeUrlRequest(url: "https://discord.com/api/users/@me", method: "GET")
        urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        let result = try JSONDecoder().decode(DiscordInfo.self, from: data)

        let profileImage = result.avatar == nil ? "https://cdn.discordapp.com/embed/avatars/" + String(Int(result.discriminator)! % 5) + ".png" :
            "https://cdn.discordapp.com/avatars/${id}/" + result.avatar! + ".png?size=2048"

        return TorusVerifierResponse(email: result.email, name: result.username + "#" + result.discriminator, profileImage: profileImage, verifier: self.params.verifier, verifierId: result.id, typeOfLogin: self.params.typeOfLogin)
    }
}
