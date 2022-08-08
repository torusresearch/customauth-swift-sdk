import Foundation
import PromiseKit
import UIKit

// MARK: - login providers

public enum LoginProviders: String {
    case google
    case facebook
    case twitch
    case reddit
    case discord
    case apple
    case github
    case linkedin
    case kakao
    case twitter
    case weibo
    case line
    case wechat
    case email_password = "Username-Password-Authentication"
    case jwt

    func getHandler(loginType: SubVerifierType, clientID: String, redirectURL: String, browserRedirectURL: String?, extraQueryParams: [String: String], jwtParams: [String: String], urlSession: URLSession = URLSession.shared) -> AbstractLoginHandler {
        switch self {
        case .google:
            return GoogleloginHandler(loginType: loginType, clientID: clientID, redirectURL: redirectURL, browserRedirectURL: browserRedirectURL, extraQueryParams: extraQueryParams, urlSession: urlSession)
        case .facebook:
            return FacebookLoginHandler(loginType: loginType, clientID: clientID, redirectURL: redirectURL, browserRedirectURL: browserRedirectURL, extraQueryParams: extraQueryParams, urlSession: urlSession)
        case .twitch:
            return TwitchLoginHandler(loginType: loginType, clientID: clientID, redirectURL: redirectURL, browserRedirectURL: browserRedirectURL, extraQueryParams: extraQueryParams, urlSession: urlSession)
        case .reddit:
            return RedditLoginHandler(loginType: loginType, clientID: clientID, redirectURL: redirectURL, browserRedirectURL: browserRedirectURL, extraQueryParams: extraQueryParams, urlSession: urlSession)
        case .discord:
            return DiscordLoginHandler(loginType: loginType, clientID: clientID, redirectURL: redirectURL, browserRedirectURL: browserRedirectURL, extraQueryParams: extraQueryParams, urlSession: urlSession)
        case .apple, .github, .linkedin, .twitter, .weibo, .kakao, .line, .wechat, .email_password, .jwt:
            return JWTLoginHandler(loginType: loginType, clientID: clientID, redirectURL: redirectURL, browserRedirectURL: browserRedirectURL, jwtParams: jwtParams, extraQueryParams: extraQueryParams, connection: self, urlSession: urlSession)
        }
    }
}
