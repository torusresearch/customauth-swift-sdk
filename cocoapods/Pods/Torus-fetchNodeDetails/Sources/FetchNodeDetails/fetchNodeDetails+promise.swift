//
//  File.swift
//
//
//  Created by Shubham on 13/3/20.
//

import Foundation
import web3
import BigInt
import PromiseKit

extension FetchNodeDetails {
    public func getCurrentEpochPromise() -> Promise<Int>{
        let function = NodeListProxyContract.CurrentEpoch(contract: self.proxyAddress)
        let transaction = try! function.transaction()
        let (tempPromise, seal) = Promise<Int>.pending()
        
        client.eth_call(transaction, block: .Latest) { (error, epoch) in
            if let epoch = epoch {
                let b = Int(hex: epoch) ?? -1
                seal.fulfill(b)
            } else{
                seal.reject(FNDError.currentEpochFailed)
            }
        }
        
        return tempPromise
    }
    
    public func getEpochInfoPromise(epoch: BigInt) -> Promise<EpochInfo>{
        let function = NodeListProxyContract.getEpochInfo(contract: self.proxyAddress, epoch: epoch)
        let transaction = try! function.transaction()
        let (tempPromise, seal) = Promise<EpochInfo>.pending()
        
        client.eth_call(transaction, block: .Latest) { (error, epoch) in
            if let epoch = epoch {
                let a = epoch.components(separatedBy: "0x")
                let b = "0x0000000000000000000000000000000000000000000000000000000000000020" + a[1]
                
                let el = try! ABIDecoder.decodeData(b, types: [EpochInfo.self])
                let decodedTuple: EpochInfo = try! el[0].decoded()
                seal.fulfill(decodedTuple)
            }else{
                seal.reject(FNDError.epochInfoFailed)
            }
        }
        
        return tempPromise
    }
    
    public func getNodeDetails(nodeEthAddress: String) -> Promise<NodeDetails> {
        let function = NodeListProxyContract.getNodeDetails(contract: self.proxyAddress, address: EthereumAddress(nodeEthAddress))
        let transaction = try! function.transaction()
        let (tempPromise, seal) = Promise<NodeDetails>.pending()
        
        client.eth_call(transaction, block: .Latest) { (error, info) in
            if let info = info {
                let a = info.components(separatedBy: "0x")
                let b = "0x0000000000000000000000000000000000000000000000000000000000000020" + a[1]
                
                let el = try! ABIDecoder.decodeData(b, types: [NodeDetails.self])
                let decodedTuple: NodeDetails = try! el[0].decoded()
                seal.fulfill(decodedTuple)
            }else{
                seal.reject(FNDError.nodeDetailsFailed)
            }
        }
        
        return tempPromise
    }
    
    
    public func getAllNodeDetails() -> Promise<AllNodeDetails>{
        let (tempPromise, seal) = Promise<AllNodeDetails>.pending()
        var torusIndexes:[BigInt] = Array()
        let currentEpoch: Int = -1;
        
        self.getCurrentEpochPromise().then{ epoch in
            return self.getEpochInfoPromise(epoch: BigInt(epoch))
        }.then{ epochInfo -> Guarantee<[Result<NodeDetails>]> in
            let nodeList = epochInfo.nodeList
            var getNodeDetailsPromiseArray:[Promise<NodeDetails>] = Array()
            
            for i in 0..<nodeList.count{
                torusIndexes.append(BigInt(i+1))
                getNodeDetailsPromiseArray.append(self.getNodeDetails(nodeEthAddress: nodeList[i].value))
            }
            return when(resolved: getNodeDetailsPromiseArray)
        }.done{results in
            var updatedEndpoints: Array<String> = Array()
            var updatedNodePub:Array<TorusNodePub> = Array()
            
            for result in results{
                switch result {
                    case .fulfilled(let value):
                        let endPointElement: NodeDetails = value;
                        let endpoint = "https://" + endPointElement.getDeclaredIp().split(separator: ":")[0] + "/jrpc";
                        updatedEndpoints.append(endpoint)
                        
                        let hexPubX = endPointElement.getPubKx()
                        let hexPubY = endPointElement.getPubKy()
                        updatedNodePub.append(TorusNodePub(_X: hexPubX.description , _Y: hexPubY.description))
                    default:
                        seal.reject("error with node info")
                }
                
            }
            
            let allNodeDetails = AllNodeDetails(_currentEpoch: "\(currentEpoch)", _nodeListAddress: self.proxyAddress.value, _torusNodeEndpoints: updatedEndpoints, _torusIndexes: torusIndexes, _torusNodePub: updatedNodePub, _updated: true)
            
            seal.fulfill(allNodeDetails)
        }.catch{error in
            print(error)
            seal.reject(FNDError.allNodeDetailsFailed)
        }
        
        return tempPromise
    }
}
