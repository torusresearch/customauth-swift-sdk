//
//  SubverifierDetails.swift
//  
//
//  Created by Shubham on 1/6/20.
//
import UIKit
import Foundation
import PromiseKit

// Type of OAuth application created. ex. google web app/iOS app
public enum SubVerifierType{
    case installed
    case web
}

// MARK: - login providers
public enum LoginProviders : String {
    case google = "google"
    case facebook = "facebook"
    case twitch = "twitch"
    case reddit = "reddit"
    case discord = "discord"
    case apple = "apple"
    case github = "github"
    case linkedin = "linkedin"
    case twitter = "twitter"
    case weibo = "weibo"
    case line = "line"
    case email_password = "Username-Password-Authentication"
    case passwordless = "email"
    case jwt = "jwt"
    
    func getHandler(loginType: SubVerifierType, clientID: String, redirectURL: String, extraParams: [String:String], jwtParams: [String: String]) -> AbstractLoginHandler{
        switch self {
        case .google:
            return GoogleloginHandler(loginType: loginType, clientID: clientID, redirectURL: redirectURL, extraParams: extraParams)
        case .facebook:
            return FacebookLoginHandler(loginType: loginType, clientID: clientID, redirectURL: redirectURL, extraParams: extraParams)
        case .twitch:
            return TwitchLoginHandler(loginType: loginType, clientID: clientID, redirectURL: redirectURL, extraParams: extraParams)
        case .reddit:
            return RedditLoginHandler(loginType: loginType, clientID: clientID, redirectURL: redirectURL, extraParams: extraParams)
        case .discord:
            return DiscordLoginHandler(loginType: loginType, clientID: clientID, redirectURL: redirectURL, extraParams: extraParams)
        case .apple:
            return JWTLoginHandler(loginType: loginType, clientID: clientID, redirectURL: redirectURL, jwtParams: jwtParams, extraParams: extraParams, connection: self)
        case .github:
            return JWTLoginHandler(loginType: loginType, clientID: clientID, redirectURL: redirectURL, jwtParams: jwtParams, extraParams: extraParams, connection: self)
        case .linkedin:
            return JWTLoginHandler(loginType: loginType, clientID: clientID, redirectURL: redirectURL, jwtParams: jwtParams, extraParams: extraParams, connection: self)
        case .twitter:
            return JWTLoginHandler(loginType: loginType, clientID: clientID, redirectURL: redirectURL, jwtParams: jwtParams, extraParams: extraParams, connection: self)
        case .weibo:
            return JWTLoginHandler(loginType: loginType, clientID: clientID, redirectURL: redirectURL, jwtParams: jwtParams, extraParams: extraParams, connection: self)
        case .line:
            return JWTLoginHandler(loginType: loginType, clientID: clientID, redirectURL: redirectURL, jwtParams: jwtParams, extraParams: extraParams, connection: self)
        case .email_password:
            return JWTLoginHandler(loginType: loginType, clientID: clientID, redirectURL: redirectURL, jwtParams: jwtParams, extraParams: extraParams, connection: self)
        case .passwordless:
            return JWTLoginHandler(loginType: loginType, clientID: clientID, redirectURL: redirectURL, jwtParams: jwtParams, extraParams: extraParams, connection: self)
        case .jwt:
            return JWTLoginHandler(loginType: loginType, clientID: clientID, redirectURL: redirectURL, jwtParams: jwtParams, extraParams: extraParams, connection: self)
        }
    }
}


public struct SubVerifierDetails {
    let loginType: SubVerifierType
    let clientId: String
    let subVerifierId: String
    let loginProvider: LoginProviders
    let redirectURL: String?
    let handler: AbstractLoginHandler

    enum codingKeys: String, CodingKey{
        case clientId
        case loginProvider
        case subVerifierId
    }
    
    public init(loginType: SubVerifierType = .web, loginProvider: LoginProviders, clientId: String, verifierName subverifierId: String, redirectURL: String? = nil, extraParams: [String:String] = [:], jwtParams: [String:String] = [:]) {
        self.loginType = loginType
        self.clientId = clientId
        self.loginProvider = loginProvider
        self.subVerifierId = subverifierId
        self.redirectURL = redirectURL
        self.handler = self.loginProvider.getHandler(loginType: loginType, clientID: self.clientId, redirectURL: self.redirectURL!, extraParams: extraParams, jwtParams: jwtParams)
    }
    
    func getLoginURL() -> String{
        return self.handler.getLoginURL()
    }
    
    func getUserInfo(responseParameters: [String:String]) -> Promise<[String:Any]>{
        return self.handler.getUserInfo(responseParameters: responseParameters)
    }
}

