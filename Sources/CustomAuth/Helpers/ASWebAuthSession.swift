//
//  File.swift
//
//
//  Created by Dhruv Jaiswal on 05/08/22.
//

import AuthenticationServices
import Foundation

open class ASWebAuthSession: NSObject, TorusURLHandlerTypes {
    var redirectURL: URL?
    // Ensure that there is a strong reference to the SFAuthenticationSession instance when the session is in progress.
    private var authSession: ASWebAuthenticationSession?
    public init(redirectURL: String) {
        self.redirectURL = URL(string: redirectURL)
    }

    public func handle(_ url: URL, modalPresentationStyle: UIModalPresentationStyle) {
        let redirectURLScheme = redirectURL?.scheme ?? CustomAuth.didHandleCallbackURL.rawValue
        authSession = ASWebAuthenticationSession(
            url: url, callbackURLScheme: redirectURLScheme) { callbackURL, authError in
                guard
                    authError == nil,
                    let callbackURL = callbackURL
                else {
                    print(authError?.localizedDescription as? String ?? "")
                    return
                }
                CustomAuth.handle(url: callbackURL)
            }
        authSession?.presentationContextProvider = self
        authSession?.start()
    }
}

extension ASWebAuthSession: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        return window ?? ASPresentationAnchor()
    }
}
