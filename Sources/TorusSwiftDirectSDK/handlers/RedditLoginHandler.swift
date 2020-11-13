//
//  RedditLoginHandler.swift
//
//
//  Created by Shubham on 13/11/20.
//

import Foundation
import PromiseKit

class RedditLoginHandler: AbstractLoginHandler{
    let loginType: SubVerifierType
    let clientID: String
    let redirectURL: String
    var userInfo: [String: Any]?
    let extraParams: [String: String]
    let defaultParams: [String:String] = ["scope": "identity", "response_type": "token", "state": "randomstate"]
    
    public init(loginType: SubVerifierType = .web, clientID: String, redirectURL: String, extraParams: [String: String] = [:]){
        self.loginType = loginType
        self.clientID = clientID
        self.redirectURL = redirectURL
        self.extraParams = extraParams
    }
    
    func getLoginURL() -> String{
        // left join
        var tempParams = self.defaultParams
        tempParams.merge(["redirect_uri": self.redirectURL, "client_id": self.clientID]){(_, new ) in new}
        tempParams.merge(self.extraParams){(_, new ) in new}
        
        // Reconstruct URL
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "www.reddit.com"
        urlComponents.path = "/api/v1/authorize"
        urlComponents.setQueryItems(with: tempParams)
        
        return urlComponents.url!.absoluteString
        //      return "https://www.reddit.com/api/v1/authorize?client_id=\(self.clientId)&redirect_uri=\(newRedirectURL)&response_type=token&scope=identity&state=dfasdfs"
    }
    
    func getVerifierFromUserInfo() -> String {
        return self.userInfo!["name"] as! String
    }
    
    func handleLogin(responseParameters: [String : String]) -> Promise<[String : Any]> {
        let (tempPromise, seal) = Promise<[String:Any]>.pending()
        
        if let accessToken = responseParameters["access_token"]{
            var request = makeUrlRequest(url: "https://oauth.reddit.com/api/v1/me", method: "GET")
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(.promise, with: request).map{
                try JSONSerialization.jsonObject(with: $0.data) as! [String:Any]
            }.done{ data in
                var json = data
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
