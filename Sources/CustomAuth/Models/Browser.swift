//
//  Browser.swift
//
//  Created by Shubham on 18/6/20.
//

import Foundation
#if os(iOS)
import UIKit

public protocol TorusURLHandlerTypes{
    func handle(_ url: URL, modalPresentationStyle: UIModalPresentationStyle)
}

public enum URLOpenerTypes : String{
    case external = "external"
    case sfsafari = "sfsafari"
}
#endif

#if os(OSX)
import AppKit

public protocol TorusURLHandlerTypes{
    func handle(_ url: URL)
}

public enum URLOpenerTypes : String{
    case external = "external"
    case sfsafari = "sfsafari"
}
#endif
