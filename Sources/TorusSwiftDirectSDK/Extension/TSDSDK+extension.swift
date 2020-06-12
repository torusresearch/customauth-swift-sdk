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
typealias torus = TorusSwiftDirectSDK

// MARK: - verifier types
public enum verifierTypes : String{
    case singleLogin = "single_login"
    case singleIdVerifier = "single_id_verifier"
    case andAggregateVerifier =  "and_aggregate_verifier"
    case orAggregateVerifier = "or_aggregate_verifier"
}

// MARK: - login providers
public enum LoginProviders : String {
    case google = "google"
    case facebook = "facebook"
    case twitch = "twitch"
    case reddit = "reddit"
    case discord = "discord"
    case auth0 = "auth0"
    
    func defaultRedirectURL() -> String{
        switch self {
        case .google:
            return "https://backend.relayer.dev.tor.us/demoapp/redirect"
        case .facebook:
            return "https://backend.relayer.dev.tor.us/demoapp/redirect"
        case .twitch:
            return "tdsdk://tdsdk/oauthCallback"
        case .reddit:
            return "tdsdk://tdsdk/oauthCallback"
        case .discord:
            return "tdsdk://tdsdk/oauthCallback"
        case .auth0:
            return "nil"
        }
    }
}

// MARK:- torus extension
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


// MARK: - Logging
//
//@available(iOS 11.0, *)
//extension TorusSwiftDirectSDK {
//    
//    static var log: LoggerProtocol?
//    
//    public static func setLogLevel(_ level: Loglevel) {
//        Self.log = DebugLogger(level)
//        TorusSwiftDirectSDK.log?.trace("Logging enabled with level: \(level)")
//    }
//}
