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
    
    public init(loginType: SubVerifierType = .web, loginProvider: LoginProviders, clientId: String, verifierName subverifierId: String, redirectURL: String, browserRedirectURL: String? = nil, extraQueryParams: [String:String] = [:], jwtParams: [String:String] = [:]) {
        self.loginType = loginType
        self.clientId = clientId
        self.loginProvider = loginProvider
        self.subVerifierId = subverifierId
        self.redirectURL = redirectURL
        self.handler = self.loginProvider.getHandler(loginType: loginType, clientID: self.clientId, redirectURL: self.redirectURL, browserRedirectURL: browserRedirectURL, extraQueryParams: extraQueryParams, jwtParams: jwtParams)
    }
    
    public func getLoginURL() -> String{
        return self.handler.getLoginURL()
    }
    
    func getUserInfo(responseParameters: [String:String]) -> Promise<[String:Any]>{
        return self.handler.getUserInfo(responseParameters: responseParameters)
    }
}

