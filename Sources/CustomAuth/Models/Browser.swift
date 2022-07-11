//
//  Browser.swift
//
//  Created by Shubham on 18/6/20.
//

import Foundation


public protocol TorusURLHandlerTypes{
    func handle(_ url: URL, modalPresentationStyle: modalPresentationStyle)
}

public enum URLOpenerTypes : String{
    case external = "external"
    case sfsafari = "sfsafari"
}

