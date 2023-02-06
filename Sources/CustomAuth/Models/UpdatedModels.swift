//
//  File.swift
//  
//
//  Created by Dhruv Jaiswal on 10/01/23.
//

import Foundation

public struct TorusSubVerifierInfo {
    public var idToken: String
    public var verifier: String
    
    public init(idToken: String, verifier: String) {
        self.idToken = idToken
        self.verifier = verifier
    }
}

public struct AggregateVerifierParams {
   public var veriferParams: [VerifierParams]
   public var subVerifierIds: [String]
   public var verifierId: String
    
    public init(veriferParams: [VerifierParams], subVerifierIds: [String], verifierId: String) {
        self.veriferParams = veriferParams
        self.subVerifierIds = subVerifierIds
        self.verifierId = verifierId
    }

    public struct VerifierParams {
       public var verifierId: String
       public var idToken: String
        
        public init(verifierId: String, idToken: String) {
            self.verifierId = verifierId
            self.idToken = idToken
        }
    }
}


public struct TorusKey{
    public var privateKey:String
    public var publicAddress:String
    
    public init(privateKey: String, publicAddress: String) {
        self.privateKey = privateKey
        self.publicAddress = publicAddress
    }
}
