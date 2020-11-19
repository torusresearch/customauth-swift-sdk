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
    let extraQueryParams: [String: String]
    let defaultParams: [String:String] = ["scope": "openid profile email", "response_type": "token id_token", "nonce": "112323", "state":"1284719kjfh9asdfawndfh"]
    let jwtParams: [String:String]
    let connection: LoginProviders
    
    public init(loginType: SubVerifierType = .web, clientID: String, redirectURL: String, jwtParams: [String: String], extraQueryParams: [String: String] = [:], connection: LoginProviders){
        self.loginType = loginType
        self.clientID = clientID
        self.redirectURL = redirectURL
        self.extraQueryParams = extraQueryParams
        self.connection = connection
        self.jwtParams = jwtParams
    }
    
    func getUserInfo(responseParameters: [String : String]) -> Promise<[String : Any]> {
        return self.handleLogin(responseParameters: responseParameters)
    }
    
    func getLoginURL() -> String{
        // left join
        var tempParams = self.defaultParams
        tempParams.merge(["redirect_uri": self.redirectURL, "client_id": self.clientID, "domain": jwtParams["domain"]!]){(_, new ) in new}
        tempParams.merge(self.extraQueryParams){(_, new ) in new}
        
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
        let res: String
        let lowerCased = self.jwtParams["isVerifierIdCaseSensitive"] ?? "false"
        
        switch self.connection {
            case .apple, .weibo, .github, .twitter, .linkedin, .line:
                res = self.userInfo!["sub"] as! String
            case .email_password, .jwt:
                res = self.userInfo!["name"] as! String
            default:
                return "verifier not supported"
        }
        
        if(lowerCased == "true") {
            return res.lowercased()
        }else{
            return res
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
                var json = data // because data is let
                self.userInfo = json
                if(responseParameters["error"] != nil){
                    throw responseParameters["error"]!
                }
                
                json["tokenForKeys"] = responseParameters["id_token"]
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
