//
//  File.swift
//  
//
//  Created by Shubham on 1/6/20.
//

import Foundation

struct SubVerifierDetails {
    let clientId: String
    let typeOfLogin: LoginProviders
    let subVerifierId: String
    
    enum codingKeys: String, CodingKey{
        case clientId
        case typeOfLogin
        case subVerifierId
    }
    
    init(dictionary: [String: String]) throws {
        self.clientId = dictionary["clientId"] ?? ""
        self.typeOfLogin = LoginProviders(rawValue: dictionary["typeOfLogin"] ?? "")!
        self.subVerifierId = dictionary["verifier"] ?? ""
    }
}

