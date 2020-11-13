//
//  File.swift
//  
//
//  Created by Shubham on 13/11/20.
//

import Foundation
import PromiseKit

class JWTLoginHandler: AbstractLoginHandler{
    let loginType: SubVerifierType
    let clientID: String
    let redirectURL: String
    var userInfo: [String: Any]?
    let extraParams: [String: String]
    let defaultParams: [String:String] = ["scope": "openid profile email", "response_type": "token id_token", "nonce": "123"]
    let jwtParams: [String:String]
    let connection: LoginProviders
    
    public init(loginType: SubVerifierType = .web, clientID: String, redirectURL: String, jwtParams: [String: String], extraParams: [String: String] = [:], connection: LoginProviders){
        self.loginType = loginType
        self.clientID = clientID
        self.redirectURL = redirectURL
        self.extraParams = extraParams
        self.connection = connection
        self.jwtParams = jwtParams
    }
    
    func getUserInfo(responseParameters: [String : String]) -> Promise<[String : Any]> {
        return self.handleLogin(responseParameters: responseParameters)
    }
    
    func getLoginURL() -> String{
        // left join
        var tempParams = self.defaultParams
        tempParams.merge(["redirect_uri": self.redirectURL, "client_id": self.clientID, "connection": self.connection.rawValue]){(_, new ) in new}
        tempParams.merge(self.extraParams){(_, new ) in new}
        
        // Reconstruct URL
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = jwtParams["domain"]
        urlComponents.path = "/authorize"
        urlComponents.setQueryItems(with: tempParams)
        
        // return string
        return urlComponents.url!.absoluteString
    }
    
    func getVerifierFromUserInfo() -> String {
        switch self.connection {
        case .apple, .weibo, .github, .twitter, .linkedin, .line:
            return self.userInfo!["sub"] as! String
        case .email_password, .passwordless:
            return self.userInfo!["name"] as! String
        default:
            return "verifier not supported"
        }
    }
    
    func handleLogin(responseParameters: [String : String]) -> Promise<[String : Any]> {
        let (tempPromise, seal) = Promise<[String:Any]>.pending()
        
        // Reconstruct URL
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = self.jwtParams["domain"]
        urlComponents.path = "/userinfo"
        
        if let accessToken = responseParameters["access_token"]{
            var request = makeUrlRequest(url: urlComponents.url!.absoluteString, method: "GET")
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(.promise, with: request).map{
                try JSONSerialization.jsonObject(with: $0.data) as! [String:Any]
            }.done{ data in
                var json = data
                print(json)
                self.userInfo = json
                json["tokenForKeys"] = accessToken
                json["verifierId"] = self.getVerifierFromUserInfo()
                seal.fulfill(json)
                
            }.catch{err in
                seal.reject(TSDSError.getUserInfoFailed)
            }
        }else{
            seal.reject(TSDSError.accessTokenNotProvided)
        }
        
        return tempPromise
    }
    
}
