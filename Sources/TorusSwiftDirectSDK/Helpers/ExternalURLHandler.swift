//
//  ExternalURLHandler.swift
//  
//
//  Created by Shubham on 18/6/20.
//

import Foundation
import UIKit


class ExternalURLHanlder: TorusURLHandlerTypes{
    
    open func handle(_ url: URL, modalPresentationStyle: UIModalPresentationStyle) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(url)
        }
    }
}
