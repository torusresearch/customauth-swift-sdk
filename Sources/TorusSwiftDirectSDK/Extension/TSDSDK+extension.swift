//
//  TorusSwiftDirectSDK class
//  TorusSwiftDirectSDK
//
//  Created by Shubham Rathi on 18/05/2020.
//

import Foundation
import UIKit
import TorusUtils
import PromiseKit

@available(iOS 11.0, *)
extension TorusSwiftDirectSDK{
    
    open class var notificationCenter: NotificationCenter {
        return NotificationCenter.default
    }
    open class var notificationQueue: OperationQueue {
        return OperationQueue.main
    }
    
    static let didHandleCallbackURL: Notification.Name = .init("TSDSDKCallbackNotification")
    
    /// Remove internal observer on authentification
    public func removeCallbackNotificationObserver() {
        if let observer = self.observer {
            TorusSwiftDirectSDK.notificationCenter.removeObserver(observer)
        }
    }
    
    func observeCallback(_ block: @escaping (_ url: URL) -> Void) {
        self.observer = TorusSwiftDirectSDK.notificationCenter.addObserver(
            forName: TorusSwiftDirectSDK.didHandleCallbackURL,
            object: nil,
            queue: OperationQueue.main) { [weak self] notification in
                self?.removeCallbackNotificationObserver()
                // print(notification.userInfo)
                if let urlFromUserInfo = notification.userInfo?["URL"] as? URL {
                    // print("calling block")
                    block(urlFromUserInfo)
                }else{
                    assertionFailure()
                }
        }
    }
    
    public func openURL(url: String) {
        print("opening URL \(url)")
        UIApplication.shared.open(URL(string: url)!)
    }
    
    func makeUrlRequest(url: String, method: String) -> URLRequest {
        var rq = URLRequest(url: URL(string: url)!)
        rq.httpMethod = method
        rq.addValue("application/json", forHTTPHeaderField: "Content-Type")
        rq.addValue("application/json", forHTTPHeaderField: "Accept")
        return rq
    }

    open class func handle(url: URL){
        let notification = Notification(name: TorusSwiftDirectSDK.didHandleCallbackURL, object: nil, userInfo: ["URL":url])
        notificationCenter.post(notification)
    }
}

enum verifierTypes : String{
    case singleLogin = "single_login"
    case singleIdVerifier = "single_id_verifier"
    case andAggregateVerifier =  "and_aggregate_verifier"
    case orAggregateVerifier = "or_aggregate_verifier"
}

enum LoginProviders : String {
    case google = "google"
    case facebook = "facebook"
    case twitch = "twitch"
    case reddit = "reddit"
    case discord = "discord"
    case auth0 = "auth0"
    
    func makeUrlRequest(url: String, method: String) -> URLRequest {
        var rq = URLRequest(url: URL(string: url)!)
        rq.httpMethod = method
        rq.addValue("application/json", forHTTPHeaderField: "Content-Type")
        rq.addValue("application/json", forHTTPHeaderField: "Accept")
        return rq
    }
    
    func getLoginURL(clientId: String) -> String{
        switch self{
        case .google:
            return "https://accounts.google.com/o/oauth2/v2/auth?response_type=token+id_token&client_id=\(clientId)&nonce=123&redirect_uri=https://backend.relayer.dev.tor.us/redirect&scope=profile+email+openid"
        case .facebook:
            return "https://www.facebook.com/v6.0/dialog/oauth?response_type=token&client_id=\(clientId)" + "&state=random&scope=public_profile email&redirect_uri=https://backend.relayer.dev.tor.us/redirect".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        case .twitch:
            return "https://id.twitch.tv/oauth2/authorize?client_id=p560duf74b2bidzqu6uo0b3ot7qaao&redirect_uri=tdsdk://tdsdk/oauthCallback"+"&response_type=token&scope=user:read:email&state=554455&force_verify=false".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        case .reddit:
            return "https://www.reddit.com/api/v1/authorize?client_id=\(clientId)&redirect_uri=tdsdk://tdsdk/oauthCallback&response_type=token&scope=identity&state=dfasdfs"
        case .discord:
            return "https://discord.com/api/oauth2/authorize?response_type=token" + "&client_id=\(clientId)&scope=email identify&redirect_uri=tdsdk://tdsdk/oauthCallback".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        case .auth0:
            break
        }
        return "false"
    }
    
    
    func getUserInfo(responseParameters: [String:String]) -> Promise<[String:Any]>{
        
        // Modify to fit closure value init
        var request: URLRequest = makeUrlRequest(url: "https://www.googleapis.com/userinfo/v2/me", method: "GET")
        var tokenForKeys = ""
        
        switch self{
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
                    json["verifierId"] = self.getUserInfoVerifier(data: json)
                    seal.fulfill(json)
                } catch {
                    print("JSON error: \(error.localizedDescription)")
                }
                
            }.resume()
        }
    }
   
    
    func getUserInfoVerifier(data: [String: Any]) -> String{
        switch self{
        case .google:
            return data["email"] as! String
        case .facebook:
            return data["id"] as! String
        case .twitch:
            let newData = data["data"] as! [[String:Any]]
            if let temp = newData.first{
                return temp["id"] as! String
            }
        case .reddit:
            return data["name"] as! String
        case .discord:
            return data["id"] as! String
        case .auth0:
            break
        }
        return "false"
    }
    
    
    func revokeAccessToken(){
        switch self{
        case .google: break
        case .facebook: break
        case .twitch: break
        case .reddit: break
        case .discord: break
        case .auth0: break
        }
    }
}

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
}

