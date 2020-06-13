//
//  NodeDetails.swift
//  
//
//  Created by Shubham on 13/3/20.
//

import Foundation
import BigInt

public class NodeDetails {
    private var currentEpoch : String?;
    private var nodeListAddress : String?;
    private var torusNodeEndpoints : Array<String>?;
    private var torusIndexes : Array<BigInt>?;
    private var torusNodePub : Array<TorusNodePub>?;
    private var updated = false;
    
    // Not currently in use
    public init(_currentEpoch : String, _nodeListAddress : String, _torusNodeEndpoints : Array<String>,  _torusIndexes : Array<BigInt>, _torusNodePub : Array<TorusNodePub>, _updated : Bool) {
        self.currentEpoch = _currentEpoch;
        self.nodeListAddress = _nodeListAddress;
        self.torusNodeEndpoints = _torusNodeEndpoints;
        self.torusIndexes = _torusIndexes;
        self.torusNodePub = _torusNodePub;
        self.updated = _updated;
    }

    public func getTorusIndexes() -> Array<BigInt> {
        return self.torusIndexes!;
    }

    public func setTorusIndexes(torusIndexes : Array<BigInt>){
        self.torusIndexes = torusIndexes;
    }

    public func getUpdated() -> Bool {
        return updated;
    }

    public func setUpdated(updated : Bool){
        self.updated = updated;
    }

    public func getCurrentEpoch() -> String{
        return currentEpoch!;
    }

    public func setCurrentEpoch( currentEpoch : String) {
        self.currentEpoch = currentEpoch;
    }

    public func getNodeListAddress() -> String {
        return nodeListAddress!;
    }

    public func setNodeListAddress(nodeListAddress : String) {
        self.nodeListAddress = nodeListAddress;
    }

    public func getTorusNodeEndpoints() ->  Array<String> {
        return torusNodeEndpoints!;
    }

    public func setTorusNodeEndpoints(torusNodeEndpoints : Array<String>) {
        self.torusNodeEndpoints = torusNodeEndpoints;
    }

    public func getTorusNodePub() -> Array<TorusNodePub> {
        return torusNodePub!;
    }

    public func setTorusNodePub(torusNodePub : Array<TorusNodePub>) {
        self.torusNodePub = torusNodePub;
    }
}
