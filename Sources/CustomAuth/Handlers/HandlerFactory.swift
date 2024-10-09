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
            return try GoogleLoginHandler(params: params)
        case .facebook:
            return try FacebookLoginHandler(params: params)
        case .twitch:
            return try TwitchLoginHandler(params: params)
        case .discord:
            return try DiscordLoginHandler(params: params)
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
                throw CASDKError.unsupportedLoginType
            }
            throw CASDKError.invalidAuth0Options
        case .email_passwordless:
            if hint == nil {
                throw CASDKError.invalidAuth0Options
            }
            return try Web3AuthPasswordlessHandler(params: params)
        case .sms_passwordless:
            if hint == nil {
                throw CASDKError.invalidAuth0Options
            }
            return try Web3AuthPasswordlessHandler(params: params)
        case .jwt: break
        }

        if idToken != nil || accessToken != nil {
            return try MockLoginHandler(params: params)
        }

        if domain == nil {
            throw CASDKError.invalidAuth0Options
        }

        return try JWTLoginHandler(params: params)
    }
}
