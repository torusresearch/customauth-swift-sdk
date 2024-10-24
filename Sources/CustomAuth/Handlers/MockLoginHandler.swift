import Foundation
import JWTDecode

internal class MockLoginHandler: AbstractLoginHandler {
    override public init(params: CreateHandlerParams) throws {
        try super.init(params: params)
        try setFinalUrl()
    }

    override public func setFinalUrl() throws {
        if self.params.jwtParams == nil {
            throw CASDKError.invalidAuth0Options
        }
        
        var connection = self.params.jwtParams?.connection
        if connection == nil {
            connection = loginToConnection(loginType: self.params.typeOfLogin)
        }

        var params: [String: String] = try (JSONSerialization.jsonObject(with: try JSONEncoder().encode(self.params.jwtParams), options: []) as! [String: String])
        params.merge([
            "state": try state(),
            "client_id": self.params.clientId,
            "connection": connection!,
            "nonce": nonce,
        ], uniquingKeysWith: { _, new in new })

        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = self.params.jwtParams?.domain
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
        let verifierIdField = self.params.jwtParams?.verifierIdField
        let isVerifierCaseSensitive = self.params.jwtParams?.isVerifierIdCaseSensitive != nil ? Bool(self.params.jwtParams!.isVerifierIdCaseSensitive)! : true
        
        if accessToken != nil {
            let domain = self.params.jwtParams?.domain
            var user_route_info = self.params.jwtParams?.user_info_route ?? "/userinfo"
        
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

            return TorusVerifierResponse(email: result.email, name: result.name, profileImage: result.picture, verifier: self.params.verifier, verifierId: try getVerifierId(userInfo: result, typeOfLogin: self.params.typeOfLogin, verifierIdField: verifierIdField, isVerifierIdCaseSensitive: isVerifierCaseSensitive), typeOfLogin: self.params.typeOfLogin)
        }

        if idToken == nil {
            throw CASDKError.idTokenNotProvided
        } else {
            let decodedToken = try decode(jwt: idToken!)
            let result = Auth0UserInfo(picture: decodedToken.body["picture"] as? String ?? "", email: decodedToken.body["email"] as? String ?? "", name: decodedToken.body["name"] as? String ?? "", sub: decodedToken.body["sub"] as? String ?? "", nickname: decodedToken.body["nickname"] as? String ?? "")

            return TorusVerifierResponse(email: result.email, name: result.name, profileImage: result.picture, verifier: self.params.verifier, verifierId: try getVerifierId(userInfo: result, typeOfLogin: self.params.typeOfLogin, verifierIdField: verifierIdField, isVerifierIdCaseSensitive: isVerifierCaseSensitive), typeOfLogin: self.params.typeOfLogin)
        }
    }
}
