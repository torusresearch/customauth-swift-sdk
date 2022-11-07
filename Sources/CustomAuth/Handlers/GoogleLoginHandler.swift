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
    let browserRedirectURL: String?
    var userInfo: [String: Any]?
    let nonce = String.randomString(length: 10)
    let state: String
    let jwtParams: [String: String]
    let defaultParams: [String:String]
    var urlSession: URLSession
    
    public init(loginType: SubVerifierType = .web, clientID: String, redirectURL: String, browserRedirectURL: String?, jwtParams: [String: String] = [:], urlSession: URLSession = URLSession.shared){
        self.loginType = loginType
        self.clientID = clientID
        self.redirectURL = redirectURL
        self.jwtParams = jwtParams
        self.browserRedirectURL = browserRedirectURL
        self.defaultParams = ["nonce": nonce, "scope": "profile+email+openid"]
        self.urlSession = urlSession
        
        let tempState = ["nonce": self.nonce, "redirectUri": self.redirectURL, "redirectToAndroid": "true"]
        let jsonData = try! JSONSerialization.data(withJSONObject: tempState, options: .prettyPrinted)
        self.state =  String(data: jsonData, encoding: .utf8)!.toBase64URL()
    }
    
    func getUserInfo(responseParameters: [String : String]) -> Promise<[String : Any]> {
        return self.handleLogin(responseParameters: responseParameters)
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
        tempParams.merge(["redirect_uri": self.browserRedirectURL ?? self.redirectURL, "client_id": self.clientID, "response_type":googleResponseType, "state": self.state]){(_, new ) in new}
        tempParams.merge(self.jwtParams){(_, new ) in new}
            
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
        return self.userInfo?["email"] as? String ?? ""
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
                
                request.httpBody = data
                // Send request to retreive access token and id_token
                self.urlSession.dataTask(.promise, with: request).compactMap{
                    try JSONSerialization.jsonObject(with: $0.data) as? [String:Any]
                }.then{ data -> Promise<(Data, Any)> in
                    
                    // Retreive user info
                    if let accessToken = data["access_token"], let idToken = data["id_token"]{
                        var request = makeUrlRequest(url: "https://www.googleapis.com/userinfo/v2/me", method: "GET")
                        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                        return self.urlSession.dataTask(.promise, with: request).map{ ($0.data, "\(idToken)")}
                    }else{
                        throw CASDKError.accessTokenNotProvided
                    }
                }.done{ data, idToken in
                    let dictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                    self.userInfo = dictionary
                    var newData:[String:Any] = ["userInfo": self.userInfo as Any]
                    newData["tokenForKeys"] = idToken
                    newData["verifierId"] = self.getVerifierFromUserInfo()
                    seal.fulfill(newData)
                }.catch{err in
                    seal.reject(CASDKError.accessTokenAPIFailed)
                }
            }else{
                seal.reject(CASDKError.authGrantNotProvided)
            }
        case .web:
            if let accessToken = responseParameters["access_token"], let idToken = responseParameters["id_token"]{
                var request = makeUrlRequest(url: "https://www.googleapis.com/userinfo/v2/me", method: "GET")
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                self.urlSession.dataTask(.promise, with: request).map{
                    try JSONSerialization.jsonObject(with: $0.data) as? [String:Any]
                }.done{ data in
                    self.userInfo =  data
                    var newData:[String:Any] = ["userInfo": self.userInfo as Any]
                    newData["tokenForKeys"] = idToken
                    newData["verifierId"] = self.getVerifierFromUserInfo()
                    seal.fulfill(newData)
                }.catch{err in
                    seal.reject(CASDKError.accessTokenAPIFailed)
                }
            }else{
                seal.reject(CASDKError.getUserInfoFailed)
            }
        }
        return tempPromise
    }
    
    
}
