//
//  TorusNodePub.swift
//  
//
//  Created by Shubham on 13/3/20.
//

import Foundation

public class TorusNodePub {
    private let X : String;
    private let Y : String;
    
    public init(_X : String, _Y : String) {
        self.X = _X;
        self.Y = _Y;
    }

    public func getX() -> String {
        return X;
    }

    public func getY() -> String {
        return Y;
    }
}
