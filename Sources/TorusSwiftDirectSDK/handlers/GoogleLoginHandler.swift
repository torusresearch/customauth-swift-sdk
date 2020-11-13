//
//  GoogleLoginHandler.swift
//  
//
//  Created by Shubham on 13/11/20.
//

import Foundation
import PromiseKit

class GoogleloginHandler: AbstractLoginHandler{
    let loginType: SubVerifierType
    let clientID: String
    let redirectURL: String
    var userInfo: [String: Any]?
    let extraParams: [String: String]
    let defaultParams: [String:String] = ["nonce": "123", "scope": "profile+email+openid"]
    
    public init(loginType: SubVerifierType = .web, clientID: String, redirectURL: String, extraParams: [String: String] = [:]){
        self.loginType = loginType
        self.clientID = clientID
        self.redirectURL = redirectURL
        self.extraParams = extraParams
    }
    
    func getLoginURL() -> String {
        // handling different OAuth applications
        let googleResponseType: String
        switch self.loginType {
        case .installed: googleResponseType = "code"
        case .web: googleResponseType = "id_token+token"
        }
        
        // left join
        var tempParams = self.defaultParams
        tempParams.merge(["redirect_uri": self.redirectURL, "client_id": self.clientID, "response_type":googleResponseType]){(_, new ) in new}
        tempParams.merge(self.extraParams){(_, new ) in new}
            
        // Reconstruct URL
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "accounts.google.com"
        urlComponents.path = "/o/oauth2/v2/auth"
        urlComponents.setQueryItems(with: tempParams)
        
        return urlComponents.url!.absoluteString
//        return "https://accounts.google.com/o/oauth2/v2/auth?response_type=\(googleResponseType)&client_id=\(self.clientID)&nonce=123&redirect_uri=\(self.redirectURL)&scope=profile+email+openid"
    }
        
    func getVerifierFromUserInfo() -> String {
        return self.userInfo!["email"] as! String
    }
    
    func handleLogin(responseParameters: [String : String]) -> Promise<[String : Any]> {
        let (tempPromise, seal) = Promise<[String:Any]>.pending()
        
        switch self.loginType {
        case .installed:
            var request: URLRequest =  makeUrlRequest(url: "https://oauth2.googleapis.com/token", method: "POST")
            var data: Data
            if let code = responseParameters["code"]{
                request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                data = "grant_type=authorization_code&redirect_uri=\(self.redirectURL)&client_id=\(self.clientID)&code=\(code)".data(using: .utf8)!
                
                // Send request to retreive access token and id_token
                URLSession.shared.uploadTask(.promise, with: request, from: data).compactMap{
                    try JSONSerialization.jsonObject(with: $0.data) as? [String:Any]
                }.then{ data -> Promise<(Data, Any)> in
                    
                    // Retreive user info
                    if let accessToken = data["access_token"], let idToken = data["id_token"]{
                        var request = makeUrlRequest(url: "https://www.googleapis.com/userinfo/v2/me", method: "GET")
                        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                        return URLSession.shared.dataTask(.promise, with: request).map{ ($0.data, "\(idToken)")}
                    }else{
                        throw TSDSError.accessTokenNotProvided
                    }
                }.done{ data, idToken in
                    var dictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                    self.userInfo = dictionary
                    dictionary["tokenForKeys"] = idToken
                    dictionary["verifierId"] = self.getVerifierFromUserInfo()
                    seal.fulfill(dictionary)
                }.catch{err in
                    seal.reject(TSDSError.accessTokenAPIFailed)
                }
            }else{
                seal.reject(TSDSError.authGrantNotProvided)
            }
        case .web:
            if let accessToken = responseParameters["access_token"], let idToken = responseParameters["id_token"]{
                var request = makeUrlRequest(url: "https://www.googleapis.com/userinfo/v2/me", method: "GET")
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                URLSession.shared.dataTask(.promise, with: request).map{
                    try JSONSerialization.jsonObject(with: $0.data) as? [String:Any]
                }.done{ data in
                    var dictionary = data!
                    dictionary["tokenForKeys"] = idToken
                    dictionary["verifierId"] = self.getVerifierFromUserInfo()
                    seal.fulfill(dictionary)
                }.catch{err in
                    seal.reject(TSDSError.accessTokenAPIFailed)
                }
            }else{
                seal.reject(TSDSError.getUserInfoFailed)
            }
        }
        return tempPromise
    }
    
    
}
