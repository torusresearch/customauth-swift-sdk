//
//  File.swift
//  
//
//  Created by Shubham on 1/6/20.
//

import Foundation
import PromiseKit

struct SubVerifierDetails {
    let clientId: String
    let typeOfLogin: LoginProviders
    let subVerifierId: String
    
    enum codingKeys: String, CodingKey{
        case clientId
        case typeOfLogin
        case subVerifierId
    }
    
    init(dictionary: [String: String]) throws {
        self.clientId = dictionary["clientId"] ?? ""
        self.typeOfLogin = LoginProviders(rawValue: dictionary["typeOfLogin"] ?? "")!
        self.subVerifierId = dictionary["verifier"] ?? ""
    }
    
    func makeUrlRequest(url: String, method: String) -> URLRequest {
        var rq = URLRequest(url: URL(string: url)!)
        rq.httpMethod = method
        rq.addValue("application/json", forHTTPHeaderField: "Content-Type")
        rq.addValue("application/json", forHTTPHeaderField: "Accept")
        return rq
    }
    
    func getLoginURL() -> String{
        switch typeOfLogin{
        case .google:
            return "https://accounts.google.com/o/oauth2/v2/auth?response_type=token+id_token&client_id=\(self.clientId)&nonce=123&redirect_uri=https://backend.relayer.dev.tor.us/redirect&scope=profile+email+openid"
        case .facebook:
            return "https://www.facebook.com/v6.0/dialog/oauth?response_type=token&client_id=\(self.clientId)" + "&state=random&scope=public_profile email&redirect_uri=https://backend.relayer.dev.tor.us/redirect".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        case .twitch:
            return "https://id.twitch.tv/oauth2/authorize?client_id=p560duf74b2bidzqu6uo0b3ot7qaao&redirect_uri=tdsdk://tdsdk/oauthCallback"+"&response_type=token&scope=user:read:email&state=554455&force_verify=false".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        case .reddit:
            return "https://www.reddit.com/api/v1/authorize?client_id=\(self.clientId)&redirect_uri=tdsdk://tdsdk/oauthCallback&response_type=token&scope=identity&state=dfasdfs"
        case .discord:
            return "https://discord.com/api/oauth2/authorize?response_type=token" + "&client_id=\(self.clientId)&scope=email identify&redirect_uri=tdsdk://tdsdk/oauthCallback".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        case .auth0:
            return "nil"
        }
    }
    
    
    func getUserInfo(responseParameters: [String:String]) -> Promise<[String:Any]>{
        
        // Modify to fit closure value init
        var request: URLRequest = makeUrlRequest(url: "https://www.googleapis.com/userinfo/v2/me", method: "GET")
        var tokenForKeys = ""
        
        switch typeOfLogin{
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
                }
                
            }.resume()
        }
    }
    
    
    func getUserInfoVerifier(data: [String: Any]) -> String?{
        switch typeOfLogin{
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
        switch typeOfLogin{
        case .google: break
        case .facebook: break
        case .twitch: break
        case .reddit: break
        case .discord: break
        case .auth0: break
        }
    }
    
}

