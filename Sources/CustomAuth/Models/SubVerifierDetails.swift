//
//  SubverifierDetails.swift
//
//
//  Created by Shubham on 1/6/20.
//
import Foundation

// Type of OAuth application created. ex. google web app/google iOS app
public enum SubVerifierType: String {
    case installed
    case web
}

// MARK: - subverifierdetails

public struct SubVerifierDetails {
    public let loginType: SubVerifierType
    public let clientId: String
    public let verifier: String
    public let loginProvider: LoginProviders
    public let redirectURL: String
    public let handler: AbstractLoginHandler
    public var urlSession: URLSession

    public enum codingKeys: String, CodingKey {
        case clientId
        case loginProvider
        case subVerifierId
    }

    public init(loginType: SubVerifierType = .web, loginProvider: LoginProviders, clientId: String, verifier: String, redirectURL: String, browserRedirectURL: String? = nil, jwtParams: [String: String] = [:], urlSession: URLSession = URLSession.shared) {
        self.loginType = loginType
        self.clientId = clientId
        self.loginProvider = loginProvider
        self.verifier = verifier
        self.redirectURL = redirectURL
        self.urlSession = urlSession
        handler = self.loginProvider.getHandler(loginType: loginType, clientID: self.clientId, redirectURL: self.redirectURL, browserRedirectURL: browserRedirectURL, jwtParams: jwtParams, urlSession: urlSession)
    }

    public func getLoginURL() -> String {
        return handler.getLoginURL()
    }

    public func getUserInfo(responseParameters: [String: String]) async throws -> [String: Any] {
        return try await handler.getUserInfo(responseParameters: responseParameters)
    }
}
