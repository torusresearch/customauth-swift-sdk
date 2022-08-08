//
//  SubverifierDetails.swift
//
//
//  Created by Shubham on 1/6/20.
//
import Foundation
import PromiseKit
import UIKit

// Type of OAuth application created. ex. google web app/google iOS app
public enum SubVerifierType: String {
    case installed
    case web
}

// MARK: - subverifierdetails

public struct SubVerifierDetails {
    public let loginType: SubVerifierType
    public let clientId: String
    public let subVerifierId: String
    public let loginProvider: LoginProviders
    public let redirectURL: String
    public let handler: AbstractLoginHandler
    public var urlSession: URLSession

    public enum codingKeys: String, CodingKey {
        case clientId
        case loginProvider
        case subVerifierId
    }

    public init(loginType: SubVerifierType = .web, loginProvider: LoginProviders, clientId: String, verifierName subverifierId: String, redirectURL: String, browserRedirectURL: String? = nil, extraQueryParams: [String: String] = [:], jwtParams: [String: String] = [:], urlSession: URLSession = URLSession.shared) {
        self.loginType = loginType
        self.clientId = clientId
        self.loginProvider = loginProvider
        subVerifierId = subverifierId
        self.redirectURL = redirectURL
        self.urlSession = urlSession
        handler = self.loginProvider.getHandler(loginType: loginType, clientID: self.clientId, redirectURL: self.redirectURL, browserRedirectURL: browserRedirectURL, extraQueryParams: extraQueryParams, jwtParams: jwtParams, urlSession: urlSession)
    }

    public func getLoginURL() -> String {
        return handler.getLoginURL()
    }

    public func getUserInfo(responseParameters: [String: String]) -> Promise<[String: Any]> {
        return handler.getUserInfo(responseParameters: responseParameters)
    }
}
