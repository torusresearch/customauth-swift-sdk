//
//  SubverifierDetails.swift
//  
//
//  Created by Shubham on 1/6/20.
//
import UIKit
import Foundation
import PromiseKit

// Type of OAuth application created. ex. google web app/google iOS app
// Currently, only google supports .installed applications
public enum SubVerifierType : String{
    case installed = "installed"
    case web = "web"
}

// MARK: - subverifierdetails
public struct SubVerifierDetails {
    let loginType: SubVerifierType
    let clientId: String
    let subVerifierId: String
    let loginProvider: LoginProviders
    let redirectURL: String
    let handler: AbstractLoginHandler
    
    enum codingKeys: String, CodingKey{
        case clientId
        case loginProvider
        case subVerifierId
    }
    
    public init(loginType: SubVerifierType = .web, loginProvider: LoginProviders, clientId: String, verifierName subverifierId: String, redirectURL: String, browserRedirectURL: String? = nil, extraQueryParams: [String:String] = [:], jwtParams: [String:String] = [:]) throws{
        self.loginType = loginType
        self.clientId = clientId
        self.loginProvider = loginProvider
        self.subVerifierId = subverifierId
        self.redirectURL = redirectURL
        self.handler = try self.loginProvider.getHandler(loginType: loginType, clientID: clientId, subverifierId: subverifierId, redirectURL: self.redirectURL, browserRedirectURL: browserRedirectURL, extraQueryParams: extraQueryParams, jwtParams: jwtParams)
    }
    
    public func getLoginURL() throws -> String{
        return try self.handler.getLoginURL()
    }
    
    public func getUserInfo(responseParameters: [String:String]) -> Promise<[String:Any]>{
        return self.handler.getUserInfo(responseParameters: responseParameters)
    }
}

