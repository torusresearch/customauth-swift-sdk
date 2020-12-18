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
    let browserRedirectURL: String?
    var userInfo: [String: Any]?
    let nonce = String.randomString(length: 10)
    let state: String
    let extraQueryParams: [String: String]
    let defaultParams: [String:String]
    let jwtParams: [String:String]
    let connection: LoginProviders
    
    public init(loginType: SubVerifierType = .web, clientID: String, redirectURL: String, browserRedirectURL: String?, jwtParams: [String: String], extraQueryParams: [String: String] = [:], connection: LoginProviders){
        self.loginType = loginType
        self.clientID = clientID
        self.redirectURL = redirectURL
        self.extraQueryParams = extraQueryParams
        self.connection = connection
        self.browserRedirectURL = browserRedirectURL
        self.jwtParams = jwtParams
        self.defaultParams = ["scope": "openid profile email", "response_type": "token id_token", "nonce": self.nonce]
        
        let tempState = ["nonce": self.nonce, "redirectUri": self.redirectURL, "redirectToAndroid": "true"]
        let jsonData = try! JSONSerialization.data(withJSONObject: tempState, options: .prettyPrinted)
        self.state =  String(data: jsonData, encoding: .utf8)!.toBase64URL()
//        self.state = ["nonce": self.nonce, "redirectUri": self.redirectURL, "redirectToAndroid": "true"].description.toBase64URL()
    }
    
    func getUserInfo(responseParameters: [String : String]) -> Promise<[String : Any]> {
        return self.handleLogin(responseParameters: responseParameters)
    }
    
    func getLoginURL() -> String{
        // left join
        var tempParams = self.defaultParams
        let paramsToJoin : [String: String] = ["redirect_uri": self.browserRedirectURL ?? self.redirectURL, "client_id": self.clientID, "domain": jwtParams["domain"]!, "state": self.state]
        tempParams.merge(paramsToJoin){(_, new ) in new}
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
        var res: String
        let lowerCased = self.jwtParams["isVerifierIdCaseSensitive"] ?? "false"
        
        if(self.extraQueryParams["verifier_id_field"] != nil){
            let field = self.extraQueryParams["verifier_id_field"]!
            res = self.userInfo![field] as! String
        }else{
            switch self.connection {
                case .apple, .weibo, .github, .twitter, .linkedin, .line, .jwt:
                    res = self.userInfo!["sub"] as! String
                case .email_password:
                    res = self.userInfo!["name"] as! String
                default:
                    return "verifier not supported"
            }
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
                self.userInfo = data
                if(responseParameters["error"] != nil){
                    throw responseParameters["error"]!
                }
                var newData:[String:Any] = ["userInfo": self.userInfo as Any]
                newData["tokenForKeys"] = responseParameters["id_token"]
                newData["verifierId"] = self.getVerifierFromUserInfo()
                seal.fulfill(newData)
                
            }.catch{err in
                seal.reject(TSDSError.getUserInfoFailed)
            }
        }else{
            seal.reject(TSDSError.accessTokenNotProvided)
        }
        
        return tempPromise
    }
    
}
