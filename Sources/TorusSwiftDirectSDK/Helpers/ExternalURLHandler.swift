//
//  ExternalURLHandler.swift
//  
//
//  Created by Shubham on 18/6/20.
//

import Foundation
import UIKit


class ExternalURLHandler: TorusURLHandlerTypes{
    
    @objc open func handle(_ url: URL,  modalPresentationStyle: UIModalPresentationStyle) {
        #if os(iOS) || os(tvOS)
        #if !OAUTH_APP_EXTENSIONS
        if #available(iOS 10.0, tvOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
        #endif
        #elseif os(watchOS)
        // WATCHOS: not implemented
        #elseif os(OSX)
        NSWorkspace.shared.open(url)
        #endif
    }
    
}
