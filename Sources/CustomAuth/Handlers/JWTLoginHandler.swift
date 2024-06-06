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

    override public init(clientId: String, verifier: String, urlScheme: String, redirectURL: String, typeOfLogin: LoginType, jwtParams: Auth0ClientOptions? = nil, customState: TorusGenericContainer? = nil) throws {
        try super.init(clientId: clientId, verifier: verifier, urlScheme: urlScheme, redirectURL: redirectURL, typeOfLogin: typeOfLogin, jwtParams: jwtParams, customState: customState)
        try setFinalUrl()
    }

    override public func setFinalUrl() throws {
        var urlComponents = URLComponents()

        if jwtParams == nil {
            throw CASDKError.invalidAuth0Options
        }
        
        var connection = jwtParams?.connection
        if connection == nil {
            connection = loginToConnection(loginType: typeOfLogin)
        }

        let encoded = try JSONEncoder().encode(jwtParams)
        let serialized = try JSONSerialization.jsonObject(with: encoded, options: [.fragmentsAllowed, .mutableContainers])
        
        var params: [String: String] = serialized as! [String: String]
        params.merge([
            "state": try state(),
            "response_type": response_type,
            "client_id": clientId,
            "prompt": prompt,
            "redirect_uri": redirectURL,
            "scope": scope,
            "connection": connection!,
            "nonce": nonce,
        ], uniquingKeysWith: { _, new in new })
        urlComponents.scheme = "https"
        urlComponents.host = jwtParams?.domain
        urlComponents.path = "/passwordless/start"
        urlComponents.setQueryItems(with: params)

        finalUrl = urlComponents
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

            return TorusVerifierResponse(email: result.email, name: result.name, profileImage: result.picture, verifier: verifier, verifierId: try jwtParams?.verifierIdField ?? getVerifierId(userInfo: result, typeOfLogin: typeOfLogin, verifierIdField: verifierIdField, isVerifierIdCaseSensitive: isVerifierCaseSensitive), typeOfLogin: typeOfLogin)
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
