import Foundation
import JWTDecode

internal class Auth0UserInfo: Codable {
    public let picture: String
    public let email: String
    public let name: String
    public let sub: String
    public let nickname: String
    
    public init(picture: String, email: String, name: String, sub: String, nickname: String) {
        self.picture = picture
        self.email = email
        self.name = name
        self.sub = sub
        self.nickname = nickname
    }
}

internal class JWTLoginHandler: AbstractLoginHandler {
    private var response_type: String = "token id_token"
    private var scope: String = "openid profile email"
    private var prompt: String = "login"

    override public init(params: CreateHandlerParams) throws {
        try super.init(params: params)
        try setFinalUrl()
    }

    override public func setFinalUrl() throws {
        var urlComponents = URLComponents()

        if self.params.jwtParams == nil {
            throw CASDKError.invalidAuth0Options
        }
        
        var connection = self.params.jwtParams?.connection
        if connection == nil {
            connection = loginToConnection(loginType: self.params.typeOfLogin)
        }

        let encoded = try JSONEncoder().encode(self.params.jwtParams)
        let serialized = try JSONSerialization.jsonObject(with: encoded, options: [.fragmentsAllowed, .mutableContainers])
        
        var params: [String: String] = serialized as! [String: String]
        params.merge([
            "state": try state(),
            "response_type": response_type,
            "client_id": self.params.clientId,
            "prompt": prompt,
            "redirect_uri": self.params.redirectURL,
            "scope": scope,
            "connection": connection!,
            "nonce": nonce,
        ], uniquingKeysWith: { _, new in new })
        urlComponents.scheme = "https"
        urlComponents.host = self.params.jwtParams?.domain
        urlComponents.path = "/authorize"
        urlComponents.setQueryItems(with: params)

        finalUrl = urlComponents
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

            return TorusVerifierResponse(email: result.email, name: result.name, profileImage: result.picture, verifier: self.params.verifier, verifierId: try self.params.jwtParams?.verifierIdField ?? getVerifierId(userInfo: result, typeOfLogin: self.params.typeOfLogin, verifierIdField: verifierIdField, isVerifierIdCaseSensitive: isVerifierCaseSensitive), typeOfLogin: self.params.typeOfLogin)
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
