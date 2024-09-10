import Foundation
import JWTDecode

internal class Web3AuthPasswordlessHandler: AbstractLoginHandler {
    private var response_type: String = "token id_token"
    private var scope: String = "openid profile email"
    private var prompt: String = "login"

    override public init(params: CreateHandlerParams) throws {
        try super.init(params: params)
        try setFinalUrl()
    }

    override public func setFinalUrl() throws {
        if self.params.jwtParams == nil {
            throw CASDKError.invalidAuth0Options
        }
        
        let domain = self.params.jwtParams?.domain
        
        var urlComponents = URLComponents()
        
        var connection = self.params.jwtParams!.connection
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
            "network": self.params.web3AuthNetwork.name,
            "flow_type": self.params.jwtParams?.flow_type?.rawValue ?? EmailFlowType.code.rawValue
        ], uniquingKeysWith: { _, new in new })
        // workaround for plus not being encoded
        params["login_hint"]! = params["login_hint"]!.replacingOccurrences(of: "+", with: "%2B")
        urlComponents.scheme = "https"
        urlComponents.host = domain ?? "passwordless.web3auth.io"
        urlComponents.path = domain == nil ? "/v6/authorize" : "/authorize"
        urlComponents.setQueryItems(with: params)

        finalUrl = urlComponents
    }

    override public func getUserInfo(params: LoginWindowResponse, storageServerUrl: String?) async throws -> TorusVerifierResponse {
        let idToken = params.idToken
        let verifierIdField = self.params.jwtParams?.verifierIdField
        let isVerifierCaseSensitive = self.params.jwtParams?.isVerifierIdCaseSensitive != nil ? Bool(self.params.jwtParams!.isVerifierIdCaseSensitive)! : true

        if idToken == nil {
            throw CASDKError.idTokenNotProvided
        } else {
            let decodedToken = try decode(jwt: idToken!)
            let result = Auth0UserInfo(picture: decodedToken.body["picture"] as? String ?? "", email: decodedToken.body["email"] as? String ?? "", name: decodedToken.body["name"] as? String ?? "", sub: "", nickname: "")

            return TorusVerifierResponse(email: result.email.lowercased(), name: result.name.lowercased(), profileImage: result.picture, verifier: self.params.verifier, verifierId: try getVerifierId(userInfo: result, typeOfLogin: self.params.typeOfLogin, verifierIdField: verifierIdField, isVerifierIdCaseSensitive: isVerifierCaseSensitive), typeOfLogin: self.params.typeOfLogin)
        }
    }
}
