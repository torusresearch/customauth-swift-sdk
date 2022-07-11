//
//  File.swift
//
//
//  Created by Dhruv Jaiswal on 08/07/22.
//

import AppKit
import Foundation
import Foundation
import WebKit
import SafariServices



/// A web view controller, which handler OAuthSwift authentification. Must be override to display a web view.
open class WebViewController:WKNavigation, TorusURLHandlerTypes, WKNavigationDelegate {
  
    var observers = [String: NSObjectProtocol]()
    // configure default presentation and dismissal code
    open var animated: Bool = true
    open var presentCompletion: (() -> Void)?
    open var dismissCompletion: (() -> Void)?
    open var delay: UInt32? = 1
    var vc:NSViewController
    /// Set false to disable present animation.
    public var presentViewControllerAnimated = true
    /// Set false to disable dismiss animation.
    public var dismissViewControllerAnimated = true

    /// How to present this view controller if parent view controller set
    ///

    
    public init(viewController: NSViewController) {
        self.vc = viewController
    }
    
   

    public func handle(_ url: URL, modalPresentationStyle: modalPresentationStyle) {
   
#if os(OSX)
    // default behaviour if this controller affected as child controller
                let key = UUID().uuidString
        let controller = WKWebView(frame: .init(x: 100, y: 100, width: 500, height: 500), configuration: WKWebViewConfiguration())
               // controller.navigationDelegate = self
               
                 vc.view.addSubview(controller)
                controller.load(URLRequest(url: url))
                    observers[key] = CustomAuth.notificationCenter.addObserver(
                    forName: CustomAuth.didHandleCallbackURL,
                    object: nil,
                    queue: OperationQueue.main,
                    using: { _ in
                        if let observer = self.observers[key] {
                            CustomAuth.notificationCenter.removeObserver(observer)
                            self.observers.removeValue(forKey: key)
                        }
                        controller.removeFromSuperview()
                        // TODO: dismiss on main queue
                    }
                )
        
        #endif
    }



    // MARK: overrides


}

public enum Present {
    case asModalWindow
    case asSheet
    case asPopover(relativeToRect: NSRect, ofView: NSView, preferredEdge: NSRectEdge, behavior: NSPopover.Behavior)
    case transitionFrom(fromViewController: NSViewController, options: NSViewController.TransitionOptions)
    case animator(animator: NSViewControllerPresentationAnimator)
    case segue(segueIdentifier: String)
}
