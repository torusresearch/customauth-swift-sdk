//
//  epochInfo.swift
//  
//
//  Created by Shubham on 13/3/20.
//

import Foundation

public class EpochInfo {
    private var id:String = "";
    private var n:String = "";
    private var k:String = "";
    private var t:String = "";
    private var nodeList: Array<String> = [];
    private var prevEpoch:String = "";
    private var nextEpoch:String = "";

    init(_id : String, _n : String, _k : String, _t : String, _nodeList: Array<String>, _prevEpoch : String, _nextEpoch : String) {
        self.id = _id;
        self.n = _n;
        self.k = _k;
        self.t = _t;
        self.nodeList = _nodeList;
        self.prevEpoch = _prevEpoch;
        self.nextEpoch = _nextEpoch;
    }

    public func getId() -> String {
        return self.id;
    }

    public func getK() -> String{
        return self.k;
    }

    public func getN() -> String{
        return self.n;
    }

    public func getNextEpoch() -> String{
        return self.nextEpoch;
    }

    public func getPrevEpoch() -> String{
        return self.prevEpoch;
    }

    public func getT() -> String{
        return self.t;
    }

    public func getNodeList() -> Array<String> {
        return self.nodeList;
    }
}
