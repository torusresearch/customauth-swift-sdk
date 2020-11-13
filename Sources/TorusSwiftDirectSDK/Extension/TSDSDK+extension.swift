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
import SafariServices


@available(iOS 11.0, *)
typealias torus = TorusSwiftDirectSDK

// MARK: - verifier types
public enum verifierTypes : String{
    case singleLogin = "single_login"
    case singleIdVerifier = "single_id_verifier"
    case andAggregateVerifier =  "and_aggregate_verifier"
    case orAggregateVerifier = "or_aggregate_verifier"
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
                self?.logger.info(notification.userInfo as Any)
                if let urlFromUserInfo = notification.userInfo?["URL"] as? URL {
                    self?.logger.debug("executing callback block")
                    block(urlFromUserInfo)
                }else{
                    assertionFailure()
                }
        }
    }
    
    public func openURL(url: String, view: UIViewController?) {
        self.logger.info("opening URL \(url)")
        
        switch self.authorizeURLHandler {
        case .external:
            logger.warning("Apple rejects application which use the extenal browser flow for user logins. If possible, please use SFSafari flow")
            let handler = ExternalURLHanlder()
            handler.handle(URL(string: url)!)
        case .sfsafari:
            guard let controller = view else{
                logger.error("UIViewController not available. Please modify triggerLogin(controller:)")
                return
            }
            let handler = SFURLHandler(viewController: controller)
            handler.handle(URL(string: url)!)
        case .none:
            logger.error("Cannot access specified browser")
        }
    }
    
    func makeUrlRequest(url: String, method: String) -> URLRequest {
        var rq = URLRequest(url: URL(string: url)!)
        rq.httpMethod = method
        rq.addValue("application/json", forHTTPHeaderField: "Content-Type")
        rq.addValue("application/json", forHTTPHeaderField: "Accept")
        return rq
    }
    
    open class func handle(url: URL){
        // TorusSwiftDirectSDK.logger.info("Posting notification after Universal link/deep link flow")
        let notification = Notification(name: TorusSwiftDirectSDK.didHandleCallbackURL, object: nil, userInfo: ["URL":url])
        notificationCenter.post(notification)
    }
    
    // Run on main block
    static func main(block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async {
                block()
            }
        }
    }
}
