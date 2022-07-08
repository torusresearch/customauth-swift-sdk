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

/// Delegate for OAuthWebViewController
public protocol OAuthWebViewControllerDelegate: AnyObject {
    func oauthWebViewControllerWillAppear()
    func oauthWebViewControllerDidAppear()
    func oauthWebViewControllerWillDisappear()
    func oauthWebViewControllerDidDisappear()
}

/// A web view controller, which handler OAuthSwift authentification. Must be override to display a web view.
open class WebViewController: CustomAuthViewController, TorusURLHandlerTypes {
    public func handle(_ url: URL) {
        doHandle(url)
    }
    
    public weak var delegate: OAuthWebViewControllerDelegate?

    /// Set false to disable present animation.
    public var presentViewControllerAnimated = true
    /// Set false to disable dismiss animation.
    public var dismissViewControllerAnimated = true
    var observers = [String: NSObjectProtocol]()

    /// How to present this view controller if parent view controller set
    


    public var present: Present = .asModalWindow

    open func doHandle(_ url: URL) {
   
#if os(OSX)
            if let p = parent { // default behaviour if this controller affected as child controller
                let key = UUID().uuidString
                switch present {
                case .asSheet:
                    p.presentAsSheet(self)
                case .asModalWindow:
                    p.presentAsModalWindow(self)
                // FIXME: if we present as window, window close must detected and oauthswift.cancel() must be called...
                case let .asPopover(positioningRect, positioningView, preferredEdge, behavior):
                    p.present(self, asPopoverRelativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge, behavior: behavior)
                case let .transitionFrom(fromViewController, options):
                    let completion: () -> Void = { /* [unowned self] in */
                        // self.delegate?.oauthWebViewControllerDidPresent()
                    }
                    p.transition(from: fromViewController, to: self, options: options, completionHandler: completion)
                case let .animator(animator):
                    p.present(self, animator: animator)
                case let .segue(segueIdentifier):
                    p.performSegue(withIdentifier: segueIdentifier, sender: self) // The segue must display self.view
                }
                
                observers[key] = CustomAuth.notificationCenter.addObserver(
                    forName: CustomAuth.didHandleCallbackURL,
                    object: nil,
                    queue: OperationQueue.main,
                    using: { _ in
                        if let observer = self.observers[key] {
                            CustomAuth.notificationCenter.removeObserver(observer)
                            self.observers.removeValue(forKey: key)
                        }
                        self.dismiss(p)
                        // TODO: dismiss on main queue
                    }
                )
            } else if let window = view.window {
                window.makeKeyAndOrderFront(nil)
            } else {
                assertionFailure("Failed to present. Add controller into a window or add a parent")
            }
            // or create an NSWindow or NSWindowController (/!\ keep a strong reference on it)
        #endif
    }

    open func dismissWebViewController() {
        if presentingViewController != nil {
            dismiss(nil)
            if parent != nil {
                removeFromParent()
            }
        } else if let window = view.window {
            window.performClose(nil)
        }
    }

    // MARK: overrides

    override open func viewWillAppear() {
        delegate?.oauthWebViewControllerWillAppear()
    }

    override open func viewDidAppear() {
        delegate?.oauthWebViewControllerDidAppear()
    }

    override open func viewWillDisappear() {
        delegate?.oauthWebViewControllerWillDisappear()
    }

    override open func viewDidDisappear() {
        delegate?.oauthWebViewControllerDidDisappear()
    }
}

public enum Present {
    case asModalWindow
    case asSheet
    case asPopover(relativeToRect: NSRect, ofView: NSView, preferredEdge: NSRectEdge, behavior: NSPopover.Behavior)
    case transitionFrom(fromViewController: NSViewController, options: NSViewController.TransitionOptions)
    case animator(animator: NSViewControllerPresentationAnimator)
    case segue(segueIdentifier: String)
}
