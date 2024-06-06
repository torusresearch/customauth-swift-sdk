import Foundation

class MockLoginHandler: AbstractLoginHandler {
    override public init(clientId: String, verifier: String, urlScheme: String, redirectURL: String, typeOfLogin: LoginType, jwtParams: Auth0ClientOptions? = nil, customState: TorusGenericContainer? = nil) throws {
        try super.init(clientId: clientId, verifier: verifier, urlScheme: urlScheme, redirectURL: redirectURL, typeOfLogin: typeOfLogin, jwtParams: jwtParams, customState: customState)
        try setFinalUrl()
    }

    override public func setFinalUrl() throws {
        if jwtParams == nil {
            throw CASDKError.invalidAuth0Options
        }

        var params: [String: String] = try (JSONSerialization.jsonObject(with: try JSONEncoder().encode(jwtParams), options: []) as! [String: String])
        params.merge([
            "state": try state(),
            "client_id": clientId,
            "nonce": nonce,
        ], uniquingKeysWith: { _, new in new })

        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = jwtParams?.domain
        urlComponents.path = "/authorize"
        urlComponents.fragment = params.compactMap({ (key, value) -> String in
            return "\(key)=\(value)"
        }).joined(separator: "&")
        finalUrl = urlComponents
    }

    override public func getUserInfo(params: LoginWindowResponse, storageServerUrl: String?) async throws -> TorusVerifierResponse {
        let accessToken = params.accessToken
        let idToken = params.idToken
        let verifierIdField = jwtParams?.verifierIdField
        let isVerifierCaseSensitive = jwtParams?.isVerifierIdCaseSensitive

        if accessToken != nil {
            let domain = jwtParams?.domain
            let user_route_info = jwtParams?.user_info_route

            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.host = domain
            urlComponents.path = user_route_info ?? ""

            var urlRequest = makeUrlRequest(url: urlComponents.string!, method: "GET")
            urlRequest.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")

            let (data, _) = try await URLSession.shared.data(for: urlRequest)

            let result = try JSONDecoder().decode(Auth0UserInfo.self, from: data)

            return TorusVerifierResponse(email: result.email, name: result.name, profileImage: result.picture, verifier: verifier, verifierId: try getVerifierId(userInfo: result, typeOfLogin: typeOfLogin, verifierIdField: verifierIdField!, isVerifierIdCaseSensitive: isVerifierCaseSensitive ?? true), typeOfLogin: typeOfLogin)
        }

        if idToken == nil {
            throw CASDKError.idTokenNotProvided
        } else {
            let result = try JSONDecoder().decode(Auth0UserInfo.self, from: idToken!.data(using: .utf8)!)

            return TorusVerifierResponse(email: result.email, name: result.name, profileImage: result.picture, verifier: verifier, verifierId: try getVerifierId(userInfo: result, typeOfLogin: typeOfLogin, verifierIdField: verifierIdField, isVerifierIdCaseSensitive: isVerifierCaseSensitive ?? true), typeOfLogin: typeOfLogin)
        }
    }
}
