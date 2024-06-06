import Foundation

internal  class HandlerFactory {
    static func createHandler(
        params: CreateHandlerParams
    ) throws -> ILoginHandler {
        if params.verifier.isEmpty {
            throw CASDKError.invalidVerifier
        }
        
        if params.clientId.isEmpty {
            throw CASDKError.invalidClientID
        }

        switch params.typeOfLogin {
        case .google:
            return try GoogleLoginHandler(clientId: params.clientId, verifier: params.verifier, urlScheme: params.urlScheme, redirectURL: params.redirectURL, typeOfLogin: params.typeOfLogin, jwtParams: params.jwtParams, customState: params.customState)
        case .facebook:
            return try FacebookLoginHandler(clientId: params.clientId, verifier: params.verifier, urlScheme: params.urlScheme, redirectURL: params.redirectURL, typeOfLogin: params.typeOfLogin, jwtParams: params.jwtParams, customState: params.customState)
        case .reddit:
            return try RedditLoginHandler(clientId: params.clientId, verifier: params.verifier, urlScheme: params.urlScheme, redirectURL: params.redirectURL, typeOfLogin: params.typeOfLogin, jwtParams: params.jwtParams, customState: params.customState)
        case .twitch:
            return try TwitchLoginHandler(clientId: params.clientId, verifier: params.verifier, urlScheme: params.urlScheme, redirectURL: params.redirectURL, typeOfLogin: params.typeOfLogin, jwtParams: params.jwtParams, customState: params.customState)
        case .discord:
            return try DiscordLoginHandler(clientId: params.clientId, verifier: params.verifier, urlScheme: params.urlScheme, redirectURL: params.redirectURL, typeOfLogin: params.typeOfLogin, jwtParams: params.jwtParams, customState: params.customState)
        case .apple: break
        case .github: break
        case .linkedin: break
        case .twitter: break
        case .weibo: break
        case .line: break
        case .email_password: break
        case .passwordless: return try PasswordlessLoginHandler(clientId: params.clientId, verifier: params.verifier, urlScheme: params.urlScheme, redirectURL: params.redirectURL, typeOfLogin: params.typeOfLogin, jwtParams: params.jwtParams, customState: params.customState)
        }

        
        if params.jwtParams?.id_token != nil || params.jwtParams?.access_token != nil {
            return try MockLoginHandler(clientId: params.clientId, verifier: params.verifier, urlScheme: params.urlScheme, redirectURL: params.redirectURL, typeOfLogin: params.typeOfLogin, jwtParams: params.jwtParams, customState: params.customState)
        }
        
        let domain = params.jwtParams?.domain
        if domain == nil {
            throw CASDKError.invalidAuth0Options
        }

        return try JWTLoginHandler(clientId: params.clientId, verifier: params.verifier, urlScheme: params.urlScheme, redirectURL: params.redirectURL, typeOfLogin: params.typeOfLogin, jwtParams: params.jwtParams, customState: params.customState)
    }
}
