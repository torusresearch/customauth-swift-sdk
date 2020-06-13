//
//  nodeInfo.swift
//  
//
//  Created by Shubham on 13/3/20.
//

import Foundation

public class NodeInfo {
    private var declaredIp: String;
    private var position: String;
    private var pubKx: String;
    private var pubKy: String;
    private var tmP2PListenAddress: String;
    private var p2pListenAddress: String;

    public init(_declaredIp : String, _position : String, _pubKx : String, _pubKy : String, _tmP2PListenAddress : String, _p2pListenAddress : String) {
        self.declaredIp = _declaredIp;
        self.position = _position;
        self.pubKx = _pubKx;
        self.pubKy = _pubKy;
        self.tmP2PListenAddress = _tmP2PListenAddress;
        self.p2pListenAddress = _p2pListenAddress;
    }

    public func getDeclaredIp() -> String {
        return declaredIp;
    }

    public func getP2pListenAddress() -> String {
        return p2pListenAddress;
    }

    public func getPosition() -> String {
        return position;
    }

    public func getPubKx() -> String {
        return pubKx;
    }

    public func getPubKy() -> String {
        return pubKy;
    }

    public func getTmP2PListenAddress() -> String {
        return tmP2PListenAddress;
    }
}
