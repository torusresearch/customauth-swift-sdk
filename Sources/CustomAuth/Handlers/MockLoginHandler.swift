import Foundation
import JWTDecode

internal class MockLoginHandler: AbstractLoginHandler {
    override public init(clientId: String, verifier: String, urlScheme: String, redirectURL: String, typeOfLogin: LoginType, jwtParams: Auth0ClientOptions? = nil, customState: TorusGenericContainer? = nil) throws {
        try super.init(clientId: clientId, verifier: verifier, urlScheme: urlScheme, redirectURL: redirectURL, typeOfLogin: typeOfLogin, jwtParams: jwtParams, customState: customState)
        try setFinalUrl()
    }

    override public func setFinalUrl() throws {
        if jwtParams == nil {
            throw CASDKError.invalidAuth0Options
        }
        
        var connection = jwtParams?.connection
        if connection == nil {
            connection = loginToConnection(loginType: typeOfLogin)
        }

        var params: [String: String] = try (JSONSerialization.jsonObject(with: try JSONEncoder().encode(jwtParams), options: []) as! [String: String])
        params.merge([
            "state": try state(),
            "client_id": clientId,
            "connection": connection!,
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

    public override func handleLoginWindow(popupFeatures: String?) async throws -> LoginWindowResponse {
        
        let urlWithTokenInfo = URL(string: finalUrl.string!)!

        var tokenInfo = parseURL(url: urlWithTokenInfo)
        let access_token = tokenInfo["access_token"]
        let id_token = tokenInfo["id_token"]
        let ref = tokenInfo["ref"]

        tokenInfo.removeValue(forKey: "access_token")
        tokenInfo.removeValue(forKey: "id_token")
        tokenInfo.removeValue(forKey: "ref")
        return LoginWindowResponse(accessToken: access_token, idToken: id_token, ref: ref ?? "", state: TorusGenericContainer(params: tokenInfo))
    }
    
    override public func getUserInfo(params: LoginWindowResponse, storageServerUrl: String?) async throws -> TorusVerifierResponse {
        let accessToken = params.accessToken
        let idToken = params.idToken
        let verifierIdField = jwtParams?.verifierIdField
        let isVerifierCaseSensitive = jwtParams?.isVerifierIdCaseSensitive != nil ? Bool(jwtParams!.isVerifierIdCaseSensitive)! : true
        
        if accessToken != nil {
            let domain = jwtParams?.domain
            var user_route_info = jwtParams?.user_info_route ?? "/userinfo"
        
            if !user_route_info.hasPrefix("/") {
                user_route_info = "/" + user_route_info
            }
            
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.host = domain
            urlComponents.path = user_route_info

            var urlRequest = makeUrlRequest(url: urlComponents.string!, method: "GET")
            urlRequest.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")

            let (data, _) = try await URLSession.shared.data(for: urlRequest)

            let result = try JSONDecoder().decode(Auth0UserInfo.self, from: data)

            return TorusVerifierResponse(email: result.email, name: result.name, profileImage: result.picture, verifier: verifier, verifierId:  try jwtParams?.verifierIdField ?? getVerifierId(userInfo: result, typeOfLogin: typeOfLogin, verifierIdField: verifierIdField, isVerifierIdCaseSensitive: isVerifierCaseSensitive), typeOfLogin: typeOfLogin)
        }

        if idToken == nil {
            throw CASDKError.idTokenNotProvided
        } else {
            let decodedToken = try decode(jwt: idToken!)
            let result = Auth0UserInfo(picture: decodedToken.body["picture"] as? String ?? "", email: decodedToken.body["email"] as? String ?? "", name: decodedToken.body["name"] as? String ?? "", sub: decodedToken.body["sub"] as? String ?? "", nickname: decodedToken.body["nickname"] as? String ?? "")

            return TorusVerifierResponse(email: result.email, name: result.name, profileImage: result.picture, verifier: verifier, verifierId:  try jwtParams?.verifierIdField ?? getVerifierId(userInfo: result, typeOfLogin: typeOfLogin, verifierIdField: verifierIdField, isVerifierIdCaseSensitive: isVerifierCaseSensitive), typeOfLogin: typeOfLogin)
        }
    }
}
