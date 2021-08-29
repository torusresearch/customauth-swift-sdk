/**
 torus utils class
 Author: Shubham Rathi
 */

import Foundation
import FetchNodeDetails
import web3
import PromiseKit
import secp256k1
import BigInt
import BestLogger

public class TorusUtils: AbstractTorusUtils{
    
    static let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY))
    
    var nodePubKeys: Array<TorusNodePub>
    let logger: BestLogger
    
    public init(label: String, loglevel: BestLogger.Level = .none, nodePubKeys: Array<TorusNodePub>){
        self.logger = BestLogger(label: label, level: loglevel)
        self.nodePubKeys = nodePubKeys
    }
    
    public convenience init(){
        self.init(label: "Torus Utils", loglevel: .info, nodePubKeys: [] )
    }
    
    public convenience init(nodePubKeys: Array<TorusNodePub>){
        self.init(label: "Torus Utils", loglevel: .info, nodePubKeys: nodePubKeys )
    }
    
    public convenience init(nodePubKeys: Array<TorusNodePub>, loglevel: BestLogger.Level){
        self.init(label: "Torus Utils", loglevel: loglevel, nodePubKeys: nodePubKeys )
    }
    
    
    public func setTorusNodePubKeys(nodePubKeys: Array<TorusNodePub>){
        self.nodePubKeys = nodePubKeys
    }
    
//    public func setEndpoints(endpoints: Array<String>){
//        self.endpoints = endpoints
//    }
    
    public func getPublicAddress(endpoints : Array<String>, torusNodePubs : Array<TorusNodePub>, verifier : String, verifierId : String, isExtended: Bool) -> Promise<[String:String]>{
        let (promise, seal) = Promise<[String:String]>.pending()
        let keyLookup = self.keyLookup(endpoints: endpoints, verifier: verifier, verifierId: verifierId)
        
        keyLookup.then{ lookupData -> Promise<[String: String]> in
            let error = lookupData["err"]
            
            if(error != nil){
                // Assign key to the user and return (wrapped in a promise)
                return self.keyAssign(endpoints: endpoints, torusNodePubs: torusNodePubs, verifier: verifier, verifierId: verifierId).then{ data -> Promise<[String:String]> in
                    // Do keylookup again
                    return self.keyLookup(endpoints: endpoints, verifier: verifier, verifierId: verifierId)
                }.then{ data -> Promise<[String: String]> in
                    let error = data["err"]
                    if(error != nil) {
                        throw TorusError.configurationError
                    }
                    return Promise<[String: String]>.value(data)
                }
            }else{
                return Promise<[String: String]>.value(lookupData)
            }
        }.then{ data in
            return self.getMetadata(dictionary: ["pub_key_X": data["pub_key_X"]!, "pub_key_Y": data["pub_key_Y"]!]).map{ ($0, data) } // Tuple
        }.done{ nonce, data in
            var newData = data
            guard
                let localPubkeyX = newData["pub_key_X"],
                let localPubkeyY = newData["pub_key_Y"]
            else { throw TorusError.runtime("Empty pubkey returned from getMetadata.") }
            
            // Convert to BigInt for modulus
            let nonce2 = BigInt(nonce).modulus(BigInt("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141", radix: 16)!)
            if(nonce != BigInt(0)) {
                let actualPublicKey = "04" + localPubkeyX.addLeading0sForLength64() + localPubkeyY.addLeading0sForLength64()
                let noncePublicKey = SECP256K1.privateToPublic(privateKey: BigUInt(nonce2).serialize().addLeading0sForLength64())
                let addedPublicKeys = self.combinePublicKeys(keys: [actualPublicKey, noncePublicKey!.toHexString()], compressed: false)
                newData["address"] = self.publicKeyToAddress(key: addedPublicKeys)
            }
            
            if(!isExtended){
                seal.fulfill(["address": newData["address"]!])
            }else{
                seal.fulfill(newData)
            }
        }.catch{err in
            self.logger.error("getPublicAddress: err: ", err)
            if let err = err as? TorusError{
                if(err == TorusError.nodesUnavailable){
                    seal.reject(err)
                }
                seal.reject(err)
            }
        }
        
        return promise
    }
    
    public func retrieveShares(endpoints : Array<String>, verifierIdentifier: String, verifierId:String, idToken: String, extraParams: Data) -> Promise<[String:String]>{
        let (promise, seal) = Promise<[String:String]>.pending()
        
        // Generate keypair
        guard
            let privateKey = self.generatePrivateKeyData(),
            let publicKey = SECP256K1.privateToPublic(privateKey: privateKey)?.subdata(in: 1..<65)
        else {
            seal.reject(TorusError.runtime("Unable to generate SECP256K1 keypair."))
            return promise
        }
        
        
        // Split key in 2 parts, X and Y
        let publicKeyHex = publicKey.toHexString()
        let pubKeyX = publicKey.prefix(publicKey.count/2).toHexString().addLeading0sForLength64()
        let pubKeyY = publicKey.suffix(publicKey.count/2).toHexString().addLeading0sForLength64()
        
        // Hash the token from OAuth login
        let timestamp = String(Int(Date().timeIntervalSince1970))
        let hashedToken = idToken.sha3(.keccak256)
        var publicAddress: String = ""
        var lookupPubkeyX: String = ""
        var lookupPubkeyY: String = ""
        
        self.logger.debug("retrieveShares:", privateKey.toHexString(), publicKeyHex, pubKeyX, pubKeyY, hashedToken)
                
        // Reject if not resolved in 30 seconds
        after(.seconds(300)).done {
            seal.reject(TorusError.timeout)
        }
        
        getPublicAddress(endpoints: endpoints, torusNodePubs: nodePubKeys, verifier: verifierIdentifier, verifierId: verifierId, isExtended: true).then{ data -> Promise<[[String:String]]> in
            publicAddress = data["address"] ?? ""
            guard
                let localPubkeyX = data["pub_key_X"]?.addLeading0sForLength64(),
                let localPubkeyY = data["pub_key_Y"]?.addLeading0sForLength64()
            else { throw TorusError.runtime("Empty pubkey returned from getPublicAddress.") }
            lookupPubkeyX = localPubkeyX
            lookupPubkeyY = localPubkeyY
            return self.commitmentRequest(endpoints: endpoints, verifier: verifierIdentifier, pubKeyX: pubKeyX, pubKeyY: pubKeyY, timestamp: timestamp, tokenCommitment: hashedToken)
        }.then{ data -> Promise<(String, String, String)> in
            self.logger.info("retrieveShares - data after commitment request:", data)
            return self.retrieveDecryptAndReconstruct(endpoints: endpoints, extraParams: extraParams, verifier: verifierIdentifier, tokenCommitment: idToken, nodeSignatures: data, verifierId: verifierId, lookupPubkeyX: lookupPubkeyX, lookupPubkeyY: lookupPubkeyY, privateKey: privateKey.toHexString())
        }.then{ x, y, key in
            return self.getMetadata(dictionary: ["pub_key_X": x, "pub_key_Y": y]).map{ ($0, key) } // Tuple
        }.done{ nonce, key in
            if(nonce != BigInt(0)) {
                let tempNewKey = BigInt(nonce) + BigInt(key, radix: 16)!
                let newKey = tempNewKey.modulus(BigInt("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141", radix: 16)!)
                self.logger.info(newKey)
                seal.fulfill(["privateKey": BigUInt(newKey).serialize().suffix(64).toHexString(), "publicAddress": publicAddress])
            }
            seal.fulfill(["privateKey":key, "publicAddress": publicAddress])
        }.catch{ err in
            self.logger.error("retrieveShares - error:",err)
            seal.reject(err)
        }.finally {
            if(promise.isPending){
                seal.reject(TorusError.unableToDerive)
            }
        }
        
        return promise
    }
}

