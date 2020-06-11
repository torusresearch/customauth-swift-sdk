//
//  SubverifierDetails.swift
//  
//
//  Created by Shubham on 1/6/20.
//
import UIKit
import Foundation
import PromiseKit

public enum SubVerifierType{
    case installed
    case web
}

public struct SubVerifierDetails {
    let loginType: SubVerifierType
    let clientId: String
    let subVerifierId: String
    let loginProvider: LoginProviders
    let redirectURL: String?

    enum codingKeys: String, CodingKey{
        case clientId
        case loginProvider
        case subVerifierId
    }
    
    public init(loginType: SubVerifierType, loginProvider: LoginProviders, clientId: String, verifierName subverifierId: String, redirectURL: String? = nil) {
        self.loginType = .installed
        self.clientId = clientId
        self.loginProvider = loginProvider
        self.subVerifierId = subverifierId
        self.redirectURL = redirectURL
        //self.clientSecret = dictionary["clientSecret"]
    }
    
    public init(dictionary: [String: String]) throws {
        self.clientId = dictionary["clientId"] ?? ""
        self.loginProvider = LoginProviders(rawValue: dictionary["loginProvider"] ?? "")!
        self.subVerifierId = dictionary["verifier"] ?? ""
        self.redirectURL = dictionary["redirectURL"]
        self.loginType = .installed
    }
    
    func makeUrlRequest(url: String, method: String) -> URLRequest {
        var rq = URLRequest(url: URL(string: url)!)
        rq.httpMethod = method
        rq.addValue("application/json", forHTTPHeaderField: "Content-Type")
        rq.addValue("application/json", forHTTPHeaderField: "Accept")
        return rq
    }
    
    func getLoginURL() -> String{
        let newRedirectURL = self.redirectURL ?? loginProvider.defaultRedirectURL()
        
        switch loginProvider{
        case .google:
            return "https://accounts.google.com/o/oauth2/v2/auth?response_type=code&client_id=\(self.clientId)&nonce=123&redirect_uri=\(newRedirectURL)&scope=profile+email+openid"
        case .facebook:
            return "https://www.facebook.com/v6.0/dialog/oauth?response_type=token&client_id=\(self.clientId)" + "&state=random&scope=public_profile email&redirect_uri=\(newRedirectURL)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        case .twitch:
            return "https://id.twitch.tv/oauth2/authorize?client_id=p560duf74b2bidzqu6uo0b3ot7qaao&redirect_uri=\(newRedirectURL)&response_type=token&scope=user:read:email&state=554455&force_verify=false".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        case .reddit:
            return "https://www.reddit.com/api/v1/authorize?client_id=\(self.clientId)&redirect_uri=\(newRedirectURL)&response_type=token&scope=identity&state=dfasdfs"
        case .discord:
            return "https://discord.com/api/oauth2/authorize?response_type=token" + "&client_id=\(self.clientId)&scope=email identify&redirect_uri=\(newRedirectURL)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        case .auth0:
            return "nil"
        }
    }
    
    func getUserInfo2(responseParameters: [String:String]) -> Promise<[String:Any]>{
        
        return handleGoogleLogin(responseParameters: responseParameters)

//        switch loginProvider{
//        case .google:
//            return handleGoogleLogin(responseParameters: responseParameters)
//        case .facebook:
//            return handleFacebookLogin(responseParameters: responseParameters)
//        case .twitch:
//            return handleTwitchLogin(responseParameters: responseParameters)
//        case .reddit:
//            return handleRedditLogin(responseParameters: responseParameters)
//        case .discord:
//            return handleDiscordLogin(responseParameters: responseParameters)
//        case .auth0:
//            break
//        }
    }
    
    func handleGoogleLogin(responseParameters: [String:String]) -> Promise<[String:Any]>{
        let (tempPromise, seal) = Promise<[String:Any]>.pending()
        
        var request : URLRequest =  makeUrlRequest(url: "https://oauth2.googleapis.com/token", method: "POST")
        var data : Data
        if let code = responseParameters["code"]{
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            let dictionary = ["grant_type": "authorization_code",
                              "redirect_uri": self.redirectURL,
                              "client_id": self.clientId,
                              "code": code]
            
//            data = try! JSONSerialization.data(withJSONObject: dictionary, options: [])
            print("grant_type=authorization_code&redirect_uri=\(self.redirectURL!)&client_id=\(self.clientId)&code=\(code)")
            
            data = "grant_type=authorization_code&redirect_uri=\(self.redirectURL!)&client_id=\(self.clientId)&code=\(code)".data(using: .utf8)!
//            print(request, String(data: data, encoding: .utf8))
            
            URLSession.shared.uploadTask(.promise, with: request, from: data).compactMap{
                try JSONSerialization.jsonObject(with: $0.data) as? [String:Any]
            }.then{ data -> Promise<(Data, Any)> in
                if let accessToken = data["access_token"], let idToken = data["id_token"]{
                    var request = self.makeUrlRequest(url: "https://www.googleapis.com/userinfo/v2/me", method: "GET")
                    request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                    return URLSession.shared.dataTask(.promise, with: request).map{ ($0.data, "\(idToken)")}
                }else{
                    throw "err"
                }
            }.done{ data, idToken in
                var dictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                dictionary["tokenForKeys"] = idToken
                dictionary["verifierId"] = self.getUserInfoVerifier(data: dictionary)
                seal.fulfill(dictionary)
            }.catch{err in
                seal.reject("Code Request failed")
            }
        }else{
            seal.reject("error occured")
        }
        return tempPromise
    }
//        func handleFacebookLogin(responseParameters: [String:String]) -> Promise<[String:Any]>{
//
//    }
//            func handleTwitchLogin(responseParameters: [String:String]) -> Promise<[String:Any]>{
//
//    }
//                func handleRedditLogin(responseParameters: [String:String]) -> Promise<[String:Any]>{
//
//    }
//                    func handleDiscordLogin(responseParameters: [String:String]) -> Promise<[String:Any]>{
//
//    }
//
    
    
    
    
    
    func getUserInfo(responseParameters: [String:String]) -> Promise<[String:Any]>{
        
        // TODO: Modify to fit closure value init
        var request: URLRequest = makeUrlRequest(url: "https://www.googleapis.com/userinfo/v2/me", method: "GET")
        var tokenForKeys = ""
        
        switch loginProvider{
        case .google:
            if let accessToken = responseParameters["access_token"], let idToken = responseParameters["id_token"]{
                request = makeUrlRequest(url: "https://www.googleapis.com/userinfo/v2/me", method: "GET")
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                tokenForKeys = idToken
            }
            break
        case .facebook:
            if let accessToken = responseParameters["access_token"]{
                request = makeUrlRequest(url: "https://graph.facebook.com/me?fields=name,email,picture.type(large)", method: "GET")
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                tokenForKeys = accessToken
            }
            break
        case .twitch:
            if let accessToken = responseParameters["access_token"]{
                request = makeUrlRequest(url: "https://api.twitch.tv/helix/users", method: "GET")
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                request.addValue("p560duf74b2bidzqu6uo0b3ot7qaao", forHTTPHeaderField: "Client-ID")
                tokenForKeys = accessToken
            }
            break
        case .reddit:
            if let accessToken = responseParameters["access_token"] {
                request = makeUrlRequest(url: "https://oauth.reddit.com/api/v1/me", method: "GET")
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                tokenForKeys = accessToken
            }
            break
        case .discord:
            if let accessToken = responseParameters["access_token"] {
                request = makeUrlRequest(url: "https://discordapp.com/api/users/@me", method: "GET")
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                tokenForKeys = accessToken
            }
            break
        case .auth0:
            break
        }
        
        return Promise<[String:Any]>{ seal in
            URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil || data == nil {
                    print("Client error!")
                    return
                }
                do {
                    var json = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                    json["tokenForKeys"] = tokenForKeys
                    json["verifierId"] = self.getUserInfoVerifier(data: json) ?? "nil"
                    seal.fulfill(json)
                } catch {
                    print("JSON error: \(error.localizedDescription)")
                    seal.reject(error)
                }
                
            }.resume()
        }
    }
    
    
    func getUserInfoVerifier(data: [String: Any]) -> String?{
        switch loginProvider{
        case .google:
            return data["email"] as? String
        case .facebook:
            return data["id"] as? String
        case .twitch:
            let newData = data["data"] as! [[String:Any]]
            if let temp = newData.first{
                return temp["id"] as? String
            }else{
                return nil
            }
        case .reddit:
            return data["name"] as? String
        case .discord:
            return data["id"] as? String
        case .auth0:
            return nil
        }
    }
    
    
    func revokeAccessToken(){
        switch loginProvider{
        case .google: break
        case .facebook: break
        case .twitch: break
        case .reddit: break
        case .discord: break
        case .auth0: break
        }
    }
    
}

