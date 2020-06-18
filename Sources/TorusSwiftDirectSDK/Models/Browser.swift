//
//  Browser.swift
//
//  Created by Shubham on 18/6/20.
//

import Foundation

public protocol TorusURLHandlerTypes{
    func handle(_ url:URL)
}

public enum URLOpenerTypes{
    case external
    case sfsafari
}
