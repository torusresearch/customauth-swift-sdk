import Foundation
#if canImport(curveSecp256k1)
    import curveSecp256k1
#endif

internal class AbstractLoginHandler: ILoginHandler {
    public var clientId: String

    public var nonce: String

    public var finalUrl: URLComponents

    public var urlScheme: String

    public var redirectURL: String

    public var verifier: String

    public var typeOfLogin: LoginType

    public var jwtParams: Auth0ClientOptions?

    public var customState: TorusGenericContainer?

    public init(clientId: String, verifier: String, urlScheme: String, redirectURL: String, typeOfLogin: LoginType, jwtParams: Auth0ClientOptions? = nil, customState: TorusGenericContainer? = nil) throws {
        self.clientId = clientId
        nonce = try SecretKey().serialize().addLeading0sForLength64()
        finalUrl = URLComponents()
        self.verifier = verifier
        self.urlScheme = urlScheme
        self.typeOfLogin = typeOfLogin
        self.jwtParams = jwtParams
        self.customState = customState
        self.redirectURL = redirectURL
    }

    public func state() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let state = State(instanceId: nonce, verifier: verifier, typeOfLogin: typeOfLogin.rawValue, redirectUri: urlScheme, customState: customState)
        return try encoder.encode(state).toBase64URL()
    }

    public func getUserInfo(params: LoginWindowResponse, storageServerUrl: String?) async throws -> TorusVerifierResponse {
        fatalError("getUserInfo must be implemented by concrete classes")
    }

    public func handleLoginWindow(popupFeatures: String?) async throws -> LoginWindowResponse {
        guard let callbackURLScheme = URL(string: urlScheme)?.scheme else {
            throw CASDKError.invalidCallbackURLScheme
        }
        
        let urlWithTokenInfo = try await AuthenticationManager().authenticationManagerWrapper(url: finalUrl.url!, callbackURLScheme: callbackURLScheme, prefersEphemeralWebBrowserSession: false)

        var tokenInfo = parseURL(url: urlWithTokenInfo)
        let access_token = tokenInfo["access_token"]
        let id_token = tokenInfo["id_token"]
        let ref = tokenInfo["ref"]

        tokenInfo.removeValue(forKey: "access_token")
        tokenInfo.removeValue(forKey: "id_token")
        tokenInfo.removeValue(forKey: "ref")
        return LoginWindowResponse(accessToken: access_token, idToken: id_token, ref: ref ?? "", state: TorusGenericContainer(params: tokenInfo))
    }

    public func setFinalUrl() throws {
        throw CASDKError.invalidMethod(msg: "setFinalUrl cannot be called by abstract class")
    }
}
