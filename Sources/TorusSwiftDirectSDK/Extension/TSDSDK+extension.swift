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

extension TorusSwiftDirectSDK{
    
    open class var notificationCenter: NotificationCenter {
        return NotificationCenter.default
    }
    open class var notificationQueue: OperationQueue {
        return OperationQueue.main
    }
    
    static let didHandleCallbackURL: Notification.Name = .init("OAuthSwiftCallbackNotificationName")
    
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
                    block(urlFromUserInfo)
                }else{
                    assertionFailure()
                }
        }
    }
    
    public func openURL(url: String) {
        // print("opening URL \(url)")
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: url)!)
        } else {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    // Todo: Change Type Function
    func makeUrlRequest(url: String) -> URLRequest {
        var rq = URLRequest(url: URL(string: url)!)
        rq.httpMethod = "POST"
        rq.addValue("application/json", forHTTPHeaderField: "Content-Type")
        rq.addValue("application/json", forHTTPHeaderField: "Accept")
        return rq
    }
    
    // Todo: Change Type Function
    func getUserInfo(accessToken : String) -> Promise<[String: Any]>{
        var request = makeUrlRequest(url: "https://www.googleapis.com/oauth2/v3/userinfo")
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return Promise<[String:Any]>{ seal in
            URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil || data == nil {
                    print("Client error!")
                    return
                }
                // print(response)
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                    // print(json)
                    seal.fulfill(json)
                } catch {
                    print("JSON error: \(error.localizedDescription)")
                }
                
            }.resume()
        }
    }
    
    open class func handle(url: URL){
        
        let notification = Notification(name: TorusSwiftDirectSDK.didHandleCallbackURL, object: nil, userInfo: ["URL":url])
        notificationCenter.post(notification)
        
        //        if let idToken = responseParameters["id_token"] {
        //             print(idToken)
        ////            torusUtils.retreiveShares(endpoints: self.endpoints, verifier: "google-shubs", verifierParams: ["verifier_id":"shubham@tor.us"], idToken: idToken).done{ data in
        ////                print(data)
        ////                self.privateKey = data
        ////            }.catch{err in
        ////                print(err)
        ////            }
        //       }
        
    }
    
    
    func getLoginURLString(svd : SubVerifierDetails) -> String{
        var returnURL : String = ""
        
        switch svd.typeOfLogin{
        case .google:
            returnURL =  "https://accounts.google.com/o/oauth2/v2/auth?response_type=token+id_token&client_id=\(svd.clientId)&nonce=123&redirect_uri=https://backend.relayer.dev.tor.us/redirect&scope=profile+email+openid"
            break
        case .facebook:
            break
        case .twitch:
            break
        case .reddit:
            break
        case .discord:
            break
        case .auth0:
            break
        }
        
        return returnURL
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
        self.subVerifierId = dictionary["subVerifierId"] ?? ""
    }
}

