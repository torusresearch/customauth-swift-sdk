//
//  AbstractLoginHandler.swift
//  
//
//  Created by Shubham on 13/11/20.
//

import Foundation

public protocol AbstractLoginHandler {
    func getLoginURL() -> String
    func getUserInfo(responseParameters: [String: String]) async throws -> [String: Any]
    func getVerifierFromUserInfo() -> String
    func handleLogin(responseParameters: [String: String]) async throws -> [String: Any]
}
