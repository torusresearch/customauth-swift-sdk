//
//  File.swift
//
//
//  Created by Dhruv Jaiswal on 05/08/22.
//

import AuthenticationServices
import Foundation

open class ASWebAuthSession: NSObject, TorusURLHandlerTypes {
    override init() {
    }

    public func handle(_ url: URL, modalPresentationStyle: UIModalPresentationStyle) {
        let authSession = ASWebAuthenticationSession(
            url: url, callbackURLScheme: CustomAuth.didHandleCallbackURL.rawValue) { callbackURL, authError in
                guard
                    authError == nil,
                    let callbackURL = callbackURL
                else {
                    print(authError?.localizedDescription)
                    return
                }
                CustomAuth.handle(url: callbackURL)
            }
        authSession.presentationContextProvider = self
        authSession.start()
    }
}

extension ASWebAuthSession: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        return window ?? ASPresentationAnchor()
    }
}
