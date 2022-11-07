//
//  CustomAuth class
//  CustomAuth
//
//  Created by Shubham Rathi on 18/05/2020.
//

import Foundation
import OSLog
import PromiseKit
import SafariServices
import TorusUtils

typealias torus = CustomAuth

// MARK: - verifier types

public enum verifierTypes: String {
    case singleLogin = "single_login"
    case singleIdVerifier = "single_id_verifier"
    case andAggregateVerifier = "and_aggregate_verifier"
    case orAggregateVerifier = "or_aggregate_verifier"
}

// MARK:- torus extension
extension CustomAuth{
    
    open class var notificationCenter: NotificationCenter {
        return NotificationCenter.default
    }

    open class var notificationQueue: OperationQueue {
        return OperationQueue.main
    }

    static let didHandleCallbackURL: Notification.Name = .init("TSDSDKCallbackNotification")

    public func removeCallbackNotificationObserver() {
        if let observer = observer {
            CustomAuth.notificationCenter.removeObserver(observer)
        }
    }

    public func observeCallback(_ block: @escaping (_ url: URL) -> Void) {
        self.observer = CustomAuth.notificationCenter.addObserver(
            forName: CustomAuth.didHandleCallbackURL,
            object: nil,
            queue: OperationQueue.main) { [weak self] notification in
                self?.removeCallbackNotificationObserver()
                os_log("notification.userInfo: %s", log: getTorusLogger(log: CASDKLogger.core, type: .info), type: .info, notification.userInfo.debugDescription)
                if let urlFromUserInfo = notification.userInfo?["URL"] as? URL {
                    os_log("executing callback block", log: getTorusLogger(log: CASDKLogger.core, type: .error), type: .error)
                    block(urlFromUserInfo)
                } else {
                    assertionFailure()
                }
            }
    }

    public func openURL(url: String, view: UIViewController?, modalPresentationStyle: UIModalPresentationStyle) {
        os_log("opening URL: %s", log: getTorusLogger(log: CASDKLogger.core, type: .info), type: .info, url)

        switch authorizeURLHandler {
        case .external:
            let handler = ExternalURLHandler()
            handler.handle(URL(string: url)!, modalPresentationStyle: modalPresentationStyle)
        case .sfsafari:
            guard let controller = view else {
                os_log("UIViewController not available. Please modify triggerLogin(controller:)", log: getTorusLogger(log: CASDKLogger.core, type: .error), type: .error)
                return
            }
            let handler = SFURLHandler(viewController: controller)
            handler.handle(URL(string: url)!, modalPresentationStyle: modalPresentationStyle)
        case .asWebAuthSession:
            let handler = ASWebAuthSession(redirectURL: self.subVerifierDetails.first?.redirectURL ?? "")
            handler.handle(URL(string: url)!, modalPresentationStyle: modalPresentationStyle)
        case .none:
            os_log("Cannot access specified browser", log: getTorusLogger(log: CASDKLogger.core, type: .error), type: .error)
        }
    }

    func makeUrlRequest(url: String, method: String) -> URLRequest {
        var rq = URLRequest(url: URL(string: url)!)
        rq.httpMethod = method
        rq.addValue("application/json", forHTTPHeaderField: "Content-Type")
        rq.addValue("application/json", forHTTPHeaderField: "Accept")
        return rq
    }

    open class func handle(url: URL) {
        // CustomAuth.logger.info("Posting notification after Universal link/deep link flow")
        let notification = Notification(name: CustomAuth.didHandleCallbackURL, object: nil, userInfo: ["URL": url])
        notificationCenter.post(notification)
    }

    public func parseURL(url: URL) -> [String: String] {
        var responseParameters = [String: String]()
        if let query = url.query {
            responseParameters += query.parametersFromQueryString
        }
        if let fragment = url.fragment, !fragment.isEmpty {
            responseParameters += fragment.parametersFromQueryString
        }
        return responseParameters
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
