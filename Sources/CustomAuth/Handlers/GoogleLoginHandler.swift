//
//  GoogleLoginHandler.swift
//  
//
//  Created by Shubham on 13/11/20.
//

import Foundation

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
    
    func getUserInfo(responseParameters: [String : String]) async throws -> [String : Any] {
        return try await self.handleLogin(responseParameters: responseParameters)
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
    
    func handleLogin(responseParameters: [String : String]) async throws -> [String : Any] {
        
        switch self.loginType {
        case .installed:
            var request: URLRequest =  makeUrlRequest(url: "https://oauth2.googleapis.com/token", method: "POST")
            var data: Data
            if let code = responseParameters["code"]{
                request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                data = "grant_type=authorization_code&redirect_uri=\(self.redirectURL)&client_id=\(self.clientID)&code=\(code)".data(using: .utf8)!
                
                request.httpBody = data
                // Send request to retreive access token and id_token
                do{
               let val = try await self.urlSession.data(for: request)
                    let valData = try JSONSerialization.jsonObject(with: val.0) as? [String:Any] ?? [:]
                    // Retreive user info
                    if let accessToken = valData["access_token"], let idToken = valData["id_token"]{
                        var request = makeUrlRequest(url: "https://www.googleapis.com/userinfo/v2/me", method: "GET")
                        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                        let val2 = try await urlSession.data(for: request)
                        let data = val2.0
                        let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                        self.userInfo = dictionary
                        var newData:[String:Any] = ["userInfo": self.userInfo as Any]
                        newData["tokenForKeys"] = idToken
                        newData["verifierId"] = self.getVerifierFromUserInfo()
                        return newData
                    }else{
                        throw CASDKError.accessTokenNotProvided
                    }
                }
                catch{
                    throw CASDKError.accessTokenAPIFailed
                }
            }else{
                throw CASDKError.authGrantNotProvided
            }
        case .web:
            if let accessToken = responseParameters["access_token"], let idToken = responseParameters["id_token"]{
                var request = makeUrlRequest(url: "https://www.googleapis.com/userinfo/v2/me", method: "GET")
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                do{
               let val = try await self.urlSession.data(for: request)
                let data = try JSONSerialization.jsonObject(with: val.0) as? [String:Any] ?? [:]
                    self.userInfo =  data
                    var newData:[String:Any] = ["userInfo": self.userInfo as Any]
                    newData["tokenForKeys"] = idToken
                    newData["verifierId"] = self.getVerifierFromUserInfo()
                    return newData
                }catch{
                    throw CASDKError.accessTokenAPIFailed
                }
            }else{
                throw CASDKError.getUserInfoFailed
            }
        }
    }
}
