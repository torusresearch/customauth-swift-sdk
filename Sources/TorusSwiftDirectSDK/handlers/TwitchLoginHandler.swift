//
//  GoogleLoginHandler.swift
//
//
//  Created by Shubham on 13/11/20.
//

import Foundation
import PromiseKit

class TwitchLoginHandler: AbstractLoginHandler{
    let loginType: SubVerifierType
    let clientID: String
    let redirectURL: String
    let browserRedirectURL: String?
    var userInfo: [String: Any]?
    let nonce = String.randomString(length: 10)
    let state: String
    let extraQueryParams: [String: String]
    let defaultParams: [String:String] = ["scope": "user:read:email", "response_type": "token", "force_verify": "false"]
    
    public init(loginType: SubVerifierType = .web, clientID: String, redirectURL: String, browserRedirectURL: String?, extraQueryParams: [String: String] = [:]){
        self.loginType = loginType
        self.clientID = clientID
        self.redirectURL = redirectURL
        self.extraQueryParams = extraQueryParams
        self.browserRedirectURL = browserRedirectURL
        
        let tempState = ["nonce": self.nonce, "redirectUri": self.redirectURL, "redirectToAndroid": "true"]
        let jsonData = try! JSONSerialization.data(withJSONObject: tempState, options: .prettyPrinted)
        self.state =  String(data: jsonData, encoding: .utf8)!.toBase64URL()
    }
    
    func getUserInfo(responseParameters: [String : String]) -> Promise<[String : Any]> {
        return self.handleLogin(responseParameters: responseParameters)
    }
    
    func getLoginURL() -> String{
        // left join
        var tempParams = self.defaultParams
        tempParams.merge(["redirect_uri": self.browserRedirectURL ?? self.redirectURL, "client_id": self.clientID, "state": self.state]){(_, new ) in new}
        tempParams.merge(self.extraQueryParams){(_, new ) in new}
        
        // Reconstruct URL
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "id.twitch.tv"
        urlComponents.path = "/oauth2/authorize"
        urlComponents.setQueryItems(with: tempParams)
        
        return urlComponents.url!.absoluteString
        //       return "https://id.twitch.tv/oauth2/authorize?client_id=p560duf74b2bidzqu6uo0b3ot7qaao&"+"redirect_uri=\(newRedirectURL)&response_type=token&scope=user:read:email&state=554455&force_verify=false".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    func getVerifierFromUserInfo() -> String {
        let newData = self.userInfo!["data"] as! [[String:Any]]
        if let temp = newData.first{
            return temp["id"] as! String
        }
        else{
            return "nil"
        }
    }
    
    func handleLogin(responseParameters: [String : String]) -> Promise<[String : Any]> {
        let (tempPromise, seal) = Promise<[String:Any]>.pending()
        
        if let accessToken = responseParameters["access_token"]{
            var request = makeUrlRequest(url: "https://api.twitch.tv/helix/users", method: "GET")
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.addValue("p560duf74b2bidzqu6uo0b3ot7qaao", forHTTPHeaderField: "Client-ID")
            
            URLSession.shared.dataTask(.promise, with: request).map{
                try JSONSerialization.jsonObject(with: $0.data) as! [String:Any]
            }.done{ data in
                self.userInfo = data
                var newData:[String:Any] = ["userInfo": self.userInfo as Any]
                newData["tokenForKeys"] = accessToken
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
