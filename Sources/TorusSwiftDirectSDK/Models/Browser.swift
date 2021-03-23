//
//  Browser.swift
//
//  Created by Shubham on 18/6/20.
//

import Foundation
import UIKit

public protocol TorusURLHandlerTypes{
    func handle(_ url: URL, modalPresentationStyle: UIModalPresentationStyle)
}

public enum URLOpenerTypes : String{
    case external = "external"
    case sfsafari = "sfsafari"
}
