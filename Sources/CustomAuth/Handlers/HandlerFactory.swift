import Foundation

internal class HandlerFactory {
    static func createHandler(
        params: CreateHandlerParams
    ) throws -> ILoginHandler {
        if params.verifier.isEmpty {
            throw CASDKError.invalidVerifier
        }

        if params.clientId.isEmpty {
            throw CASDKError.invalidClientID
        }

        let domain = params.jwtParams?.domain
        let hint = params.jwtParams?.login_hint
        let idToken = params.jwtParams?.id_token
        let accessToken = params.jwtParams?.access_token
        
        switch params.typeOfLogin {
        case .google:
            return try GoogleLoginHandler(clientId: params.clientId, verifier: params.verifier, urlScheme: params.urlScheme, redirectURL: params.redirectURL, typeOfLogin: params.typeOfLogin, jwtParams: params.jwtParams, customState: params.customState)
        case .facebook:
            return try FacebookLoginHandler(clientId: params.clientId, verifier: params.verifier, urlScheme: params.urlScheme, redirectURL: params.redirectURL, typeOfLogin: params.typeOfLogin, jwtParams: params.jwtParams, customState: params.customState)
        case .twitch:
            return try TwitchLoginHandler(clientId: params.clientId, verifier: params.verifier, urlScheme: params.urlScheme, redirectURL: params.redirectURL, typeOfLogin: params.typeOfLogin, jwtParams: params.jwtParams, customState: params.customState)
        case .discord:
            return try DiscordLoginHandler(clientId: params.clientId, verifier: params.verifier, urlScheme: params.urlScheme, redirectURL: params.redirectURL, typeOfLogin: params.typeOfLogin, jwtParams: params.jwtParams, customState: params.customState)
        case .reddit: break
        case .apple: break
        case .github: break
        case .linkedin: break
        case .twitter: break
        case .weibo: break
        case .line: break
        case .email_password: break
        case .passwordless:
            if domain == nil || hint == nil {
                throw CASDKError.invalidAuth0Options
            }
            return try PasswordlessLoginHandler(clientId: params.clientId, verifier: params.verifier, urlScheme: params.urlScheme, redirectURL: params.redirectURL, typeOfLogin: params.typeOfLogin, jwtParams: params.jwtParams, customState: params.customState)
        case .email_passwordless:
            if domain == nil || hint == nil {
                throw CASDKError.invalidAuth0Options
            }
            throw CASDKError.invalidAuth0Options
        // TODO: implement web3authpasswordlesshandler for this
        case .sms_passwordless:
            if hint == nil {
                throw CASDKError.invalidAuth0Options
            }
            throw CASDKError.invalidAuth0Options
        // TODO: implement web3authpasswordlesshandler for this
        case .jwt: break
        }

        if idToken != nil || accessToken != nil {
            return try MockLoginHandler(clientId: params.clientId, verifier: params.verifier, urlScheme: params.urlScheme, redirectURL: params.redirectURL, typeOfLogin: params.typeOfLogin, jwtParams: params.jwtParams, customState: params.customState)
        }

        if domain == nil {
            throw CASDKError.invalidAuth0Options
        }

        return try JWTLoginHandler(clientId: params.clientId, verifier: params.verifier, urlScheme: params.urlScheme, redirectURL: params.redirectURL, typeOfLogin: params.typeOfLogin, jwtParams: params.jwtParams, customState: params.customState)
    }
}
