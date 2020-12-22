//
//  File.swift
//  
//
//  Created by Shubham on 25/3/20.
//

import Foundation
import PromiseKit
import FetchNodeDetails
#if canImport(PMKFoundation)
import PMKFoundation
#endif
#if canImport(secp256k1)
import secp256k1
#endif
import BigInt
import CryptoSwift
import web3swift

@available(iOS 9.0, *)
extension TorusUtils {
    
    func makeUrlRequest(url: String) -> URLRequest {
        var rq = URLRequest(url: URL(string: url)!)
        rq.httpMethod = "POST"
        rq.addValue("application/json", forHTTPHeaderField: "Content-Type")
        rq.addValue("application/json", forHTTPHeaderField: "Accept")
        return rq
    }
    
    func thresholdSame<T:Hashable>(arr: Array<T>, threshold: Int) -> T?{
        // print(threshold)
        var hashmap = [T:Int]()
        for (_, value) in arr.enumerated(){
            if((hashmap[value]) != nil) {hashmap[value]! += 1}
            else { hashmap[value] = 1 }
            if (hashmap[value] == threshold){
                return value
            }
            //print(hashmap)
        }
        return nil
    }
    
    func ecdh(pubKey: secp256k1_pubkey, privateKey: Data) -> secp256k1_pubkey? {
        var pubKey2 = pubKey // Pointer takes a variable
        if (privateKey.count != 32) {return nil}
        let result = privateKey.withUnsafeBytes { (a: UnsafeRawBufferPointer) -> Int32? in
            if let pkRawPointer = a.baseAddress, a.count > 0 {
                let privateKeyPointer = pkRawPointer.assumingMemoryBound(to: UInt8.self)
                let res = secp256k1_ec_pubkey_tweak_mul(TorusUtils.context!, UnsafeMutablePointer<secp256k1_pubkey>(&pubKey2), privateKeyPointer)
                return res
            } else {
                return nil
            }
        }
        guard let res = result, res != 0 else {
            return nil
        }
        return pubKey2
    }
    
    // MARK: metadata API
    func getMetadata(dictionary: [String:String]) -> Promise<BigUInt>{
        
        // Enode data
        let encoded = try! JSONSerialization.data(withJSONObject: dictionary, options: [])
        let rq = self.makeUrlRequest(url: "https://metadata.tor.us/get");
        let request = URLSession.shared.uploadTask(.promise, with: rq, from: encoded)
        
        let (tempPromise, seal) = Promise<BigUInt>.pending()
        
        request.compactMap {
            try JSONSerialization.jsonObject(with: $0.data) as? [String: Any]
        }.done{ data in
            self.logger.info("metdata response: ", data)
            seal.fulfill(BigUInt(data["message"] as! String, radix: 16)!)
        }.catch{ err in
            seal.fulfill(BigUInt("0", radix: 16)!)
        }
        
        return tempPromise
    }
//    
//    func addMetaData() -> Promise<BigInt>{
//        
//    }
    
    // MARK:- commitment request
    func commitmentRequest(endpoints : Array<String>, verifier: String, pubKeyX: String, pubKeyY: String, timestamp: String, tokenCommitment: String) -> Promise<[[String:String]]>{
        
        // Todo: Add try catch for encoding block
        let encoder = JSONEncoder()
        let rpcdata = try! encoder.encode(JSONRPCrequest(
            method: "CommitmentRequest",
            params: ["messageprefix": "mug00",
                     "tokencommitment": tokenCommitment,
                     "temppubx": pubKeyX,
                     "temppuby": pubKeyY,
                     "verifieridentifier":verifier,
                     "timestamp": timestamp]
        ))
        
        // Build promises array
        var promisesArray = Array<Promise<(data: Data, response: URLResponse)> >()
        for el in endpoints {
            let rq = self.makeUrlRequest(url: el);
            promisesArray.append(URLSession.shared.uploadTask(.promise, with: rq, from: rpcdata))
        }
        
        // Array to store intermediate results
        var resultArrayStrings = Array<Any?>.init(repeating: nil, count: promisesArray.count)
        var resultArrayObjects = Array<JSONRPCresponse?>.init(repeating: nil, count: promisesArray.count)
        
        let (tempPromise, seal) = Promise<[[String:String]]>.pending()
        for (i, pr) in promisesArray.enumerated(){
            pr.done{ data, response in
                
                let encoder = JSONEncoder()
                let decoded = try JSONDecoder().decode(JSONRPCresponse.self, from: data)
                self.logger.info("commitmentRequest: reponse: ", decoded)
                
                if(decoded.error != nil) {
                    self.logger.warning("CommitmentRequest: error: ", decoded)
                    // print(try! JSONSerialization.jsonObject(with: data, options: []))
                    throw TorusError.commitmentRequestFailed
                }
                
                // check if k+t responses are back
                resultArrayStrings[i] = String(data: try encoder.encode(decoded), encoding: .utf8)
                resultArrayObjects[i] = decoded
                
                let lookupShares = resultArrayStrings.filter{ $0 as? String != nil } // Nonnil elements
                if(lookupShares.count >= Int(endpoints.count/4)*3+1 && !tempPromise.isFulfilled){
                    let nodeSignatures = resultArrayObjects.compactMap{ $0 }.map{return $0.result as! [String:String]}
                    self.logger.trace("CommitmentRequest: nodeSignatures: ", nodeSignatures)
                    seal.fulfill(nodeSignatures)
                }
            }.catch{ err in
                self.logger.error("CommitmentRequest: err: ", err)
                seal.reject(err)
            }
        }
        return tempPromise
    }
    
    // MARK:- retrieve each node shares
    func retrieveIndividualNodeShare(endpoints : Array<String>, extraParams: Data, verifier: String, tokenCommitment:String, nodeSignatures: [[String:String]], verifierId: String) -> Promise<[Int:[String:String]]>{
        
        // Rebuild extraParams
        var rpcdata : Data = Data.init()
        do {
            if let loadedStrings = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(extraParams) as? [String:Any] {
                // print(loadedStrings)
                let newValue = ["verifieridentifier":verifier, "verifier_id": verifierId, "nodesignatures": nodeSignatures, "idtoken": tokenCommitment] as [String:AnyObject]
                let keepingCurrent = loadedStrings.merging(newValue) { (current, _) in current }
                
                // todo : look into hetrogeneous array encoding
                let dataForRequest = ["jsonrpc": "2.0",
                                      "id":10,
                                      "method": "ShareRequest",
                                      "params": ["encrypted": "yes",
                                                 "item": [keepingCurrent]]] as [String : Any]
                rpcdata = try! JSONSerialization.data(withJSONObject: dataForRequest)
            }
        } catch {
            self.logger.error("RetrieveIndividualNodeShare: Couldn't read file.")
        }
        
        // Build promises array
        var promisesArrayReq = Array<Promise<(data: Data, response: URLResponse)> >()
        for el in endpoints {
            let rq = self.makeUrlRequest(url: el);
            promisesArrayReq.append(URLSession.shared.uploadTask(.promise, with: rq, from: rpcdata))
        }
        
        let (tempPromise, seal) = Promise<[Int:[String:String]]>.pending()
        var ShareResponses = Array<[String:String]?>.init(repeating: nil, count: promisesArrayReq.count)
        var resultArray = [Int:[String:String]]()
        
        for (i, pr) in promisesArrayReq.enumerated(){
            pr.done{ data, response in
                self.logger.info("retreiveIndividualNodeShares: ",String(decoding: data, as: UTF8.self))
                let decoded = try JSONDecoder().decode(JSONRPCresponse.self, from: data)
                if(decoded.error != nil) {
                    self.logger.info("retreiveIndividualNodeShares: err: ", decoded)
                    throw TorusError.decodingError
                }
                
                let decodedResult = decoded.result as? [String:Any]
                let keyObj = decodedResult!["keys"] as? [[String:Any]]
                
                // Due to multiple keyAssign
                if let temp = keyObj?.first{
                    let metadata = temp["Metadata"] as! [String : String]
                    let share = temp["Share"] as! String
                    let publicKey = temp["PublicKey"] as! [String : String]
                    
                    ShareResponses[i] = publicKey //For threshold
                    
                    resultArray[i] = ["iv": metadata["iv"]!, "ephermalPublicKey": metadata["ephemPublicKey"]!, "share": share, "pubKeyX": publicKey["X"]!, "pubKeyY": publicKey["Y"]!]
                }
                
                let lookupShares = ShareResponses.filter{ $0 != nil } // Nonnil elements
                
                // Comparing dictionaries, so the order of keys doesn't matter
                let keyResult = self.thresholdSame(arr: lookupShares.map{$0}, threshold: Int(endpoints.count/2)+1) // Check if threshold is satisfied
                if(keyResult != nil && !tempPromise.isFulfilled){
                    self.logger.info("retreiveIndividualNodeShares: fulfill: ", resultArray)
                    seal.fulfill(resultArray)
                }
            }.catch{ err in
                self.logger.error("retreiveIndividualNodeShares: errReject: ", err)
                seal.reject(err)
            }
        }
        
        return tempPromise
    }
    
    // MARK:- decrypt shares
    func decryptIndividualShares(shares: [Int:[String:String]], privateKey: String) -> Promise<[Int:String]>{
        let (tempPromise, seal) = Promise<[Int:String]>.pending()
        
        var result = [Int:String]()
        
        for(_, el) in shares.enumerated(){
            
            let nodeIndex = el.key
            
            let ephermalPublicKey = el.value["ephermalPublicKey"]?.strip04Prefix()
            let ephermalPublicKeyBytes = ephermalPublicKey?.hexa
            var ephermOne = ephermalPublicKeyBytes?.prefix(32)
            var ephermTwo = ephermalPublicKeyBytes?.suffix(32)
            // Reverse because of C endian array storage
            ephermOne?.reverse(); ephermTwo?.reverse();
            ephermOne?.append(contentsOf: ephermTwo!)
            let ephemPubKey = secp256k1_pubkey.init(data: array32toTuple(Array(ephermOne!)))
            
            // Calculate g^a^b, i.e., Shared Key
            let sharedSecret = ecdh(pubKey: ephemPubKey, privateKey: Data.init(hexString: privateKey)!)
            let sharedSecretData = sharedSecret!.data
            let sharedSecretPrefix = tupleToArray(sharedSecretData).prefix(32)
            let reversedSharedSecret = sharedSecretPrefix.reversed()
            // print(sharedSecretPrefix.hexa, reversedSharedSecret.hexa)
            
            let share = el.value["share"]!.fromBase64()!.hexa
            let iv = el.value["iv"]?.hexa
            
            let newXValue = reversedSharedSecret.hexa
            let hash = SHA2(variant: .sha512).calculate(for: newXValue.hexa).hexa
            let AesEncryptionKey = hash.prefix(64)
            
            do{
                // AES-CBCblock-256
                let aes = try AES(key: AesEncryptionKey.hexa, blockMode: CBC(iv: iv!), padding: .pkcs7)
                let decrypt = try aes.decrypt(share)
                result[nodeIndex] = decrypt.hexa
                if(shares.count == result.count) {
                    seal.fulfill(result) // Resolve if all shares decrypt
                }
            }catch{
                seal.reject(TorusError.decryptionFailed)
            }
        }
        return tempPromise
    }
    
    func lagrangeInterpolation(shares: [Int:String]) -> Promise<String>{
        let (tempPromise, seal) = Promise<String>.pending()
        let secp256k1N = BigInt("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141", radix: 16)!;
        
        // Convert shares to BigInt(Shares)
        var shareList = [BigInt:BigInt]()
        _ = shares.map { shareList[BigInt($0.key+1)] = BigInt($0.value, radix: 16)}
        self.logger.info(shares, shareList)
        
        var secret = BigUInt("0") // to support BigInt 4.0 dependency on cocoapods
        let serialQueue = DispatchQueue(label: "lagrange.serial.queue")
        let semaphore = DispatchSemaphore(value: 1)
        var sharesDecrypt = 0
        
        for (i, share) in shareList {
            serialQueue.async{
                
                // Wait for signal
                semaphore.wait()
                
                //print(i, share)
                var upper = BigInt(1);
                var lower = BigInt(1);
                for (j, _) in shareList {
                    if (i != j) {
                        // print(j, i)
                        let negatedJ = j*BigInt(-1)
                        upper = upper*negatedJ
                        upper = upper.modulus(secp256k1N)
                        
                        var temp = i-j;
                        temp = temp.modulus(secp256k1N);
                        lower = (lower*temp).modulus(secp256k1N);
                        // print("i \(i) j \(j) upper \(upper) lower \(lower)")
                    }
                }
                var delta = (upper*(lower.inverse(secp256k1N)!)).modulus(secp256k1N);
                // print("delta", delta, "inverse of lower", lower.inverse(secp256k1N)!)
                delta = (delta*share).modulus(secp256k1N)
                secret = BigUInt((BigInt(secret)+delta).modulus(secp256k1N))
                sharesDecrypt += 1
                
                let secretString = String(secret.serialize().hexa.suffix(64))
                // print("secret is", secretString, secret, "\n")
                if(sharesDecrypt == shareList.count){
                    seal.fulfill(secretString)
                }
                semaphore.signal()
            }
        }
        return tempPromise
    }
    
    // MARK:- keylookup
    public func keyLookup(endpoints : Array<String>, verifier : String, verifierId : String) -> Promise<[String:String]>{
        let (tempPromise, seal) = Promise<[String:String]>.pending()
        
        // Enode data
        let encoder = JSONEncoder()
        let rpcdata = try! encoder.encode(JSONRPCrequest(method: "VerifierLookupRequest", params: ["verifier":verifier, "verifier_id":verifierId]))
        //print( String(data: rpcdata, encoding: .utf8)!)
        
        // Create Array of URLRequest Promises
        var promisesArray = Array<Promise<(data: Data, response: URLResponse)> >()
        for el in endpoints {
            let rq = self.makeUrlRequest(url: el);
            promisesArray.append(URLSession.shared.uploadTask(.promise, with: rq, from: rpcdata))
        }
        
        var resultArray = Array<[String:String]?>.init(repeating: nil, count: promisesArray.count)
        for (i, pr) in promisesArray.enumerated() {
            pr.done{ data, response in
                // print("keyLookup", String(data: data, encoding: .utf8))
                let decoder = try? JSONDecoder().decode(JSONRPCresponse.self, from: data) // User decoder to covert to struct
                if(decoder == nil) { throw TorusError.decodingError }
                //print(decoder)
                let result = decoder!.result
                let error = decoder?.error
                if(error == nil){
                    let decodedResult = result as! [String:[[String:String]]]
                    let keys = decodedResult["keys"]![0] as [String:String]
                    resultArray[i] = keys // Encode the result and error into string and push to array
                }else{
                    resultArray[i] = ["err": "keyLookupfailed"]
                }
                
                // print(resultArray[i])
                let lookupShares = resultArray.filter{ $0 != nil } // Nonnil elements
                let keyResult = self.thresholdSame(arr: lookupShares, threshold: Int(endpoints.count/2)+1) // Check if threshold is satisfied
                // print("threshold result", keyResult)
                if(keyResult != nil && !tempPromise.isFulfilled)  {
                    self.logger.trace("keyLookup: fulfill: ", keyResult!!)
                    seal.fulfill(keyResult!!)
                }
            }.catch{error in
                // Node returned error handling is done above
                self.logger.warning("keyLookup: err: ", error)
                seal.reject(error)
            }
        }
        return tempPromise
    }
    
    // MARK:- key assignment
    public func keyAssign(endpoints : Array<String>, torusNodePubs : Array<TorusNodePub>, verifier : String, verifierId : String) -> Promise<JSONRPCresponse> {
        let (tempPromise, seal) = Promise<JSONRPCresponse>.pending()
        self.logger.trace("KeyAssign: endpoints: ", endpoints)
        var newEndpoints = endpoints
        let newEndpoints2 = newEndpoints // used for maintaining indexes
        newEndpoints.shuffle() // To avoid overloading a single node
        
        // Serial execution required because keyassign should be done only once
        let serialQueue = DispatchQueue(label: "keyassign.serial.queue")
        let semaphore = DispatchSemaphore(value: 1)
        
        for (i, endpoint) in newEndpoints.enumerated() {
            serialQueue.async {
                // Wait for the signal
                semaphore.wait()
                
                let encoder = JSONEncoder()
                if #available(iOS 11.0, *) {
                    encoder.outputFormatting = .sortedKeys
                } else {
                    // Fallback on earlier versions
                }
                let index = newEndpoints2.firstIndex(of: endpoint)!
                self.logger.trace("KeyAssign: i: endpoint: ", index, endpoint)
                let SignerObject = JSONRPCrequest(method: "KeyAssign", params: ["verifier":verifier, "verifier_id":verifierId])
                let rpcdata = try! encoder.encode(SignerObject)
                var request = self.makeUrlRequest(url:  "https://signer.tor.us/api/sign")
                request.addValue(torusNodePubs[index].getX().lowercased(), forHTTPHeaderField: "pubKeyX")
                request.addValue(torusNodePubs[index].getY().lowercased(), forHTTPHeaderField: "pubKeyY")
                self.logger.trace("KeyAssign: nodekeys: ", torusNodePubs[index].getX().lowercased(), torusNodePubs[index].getY().lowercased())
                self.logger.trace("KeyAssign: requestToSigner: ", String(data: rpcdata, encoding: .utf8) as Any )
                
                firstly {
                    URLSession.shared.uploadTask(.promise, with: request, from: rpcdata)
                }.then{ data, response -> Promise<(data: Data, response: URLResponse)> in
                    self.logger.trace("KeyAssign: responseFromSigner: ", String(decoding: data, as: UTF8.self))
                    
                    let decodedSignerResponse = try JSONDecoder().decode(SignerResponse.self, from: data)
                    let keyassignRequest = KeyAssignRequest(params: ["verifier":verifier, "verifier_id":verifierId], signerResponse: decodedSignerResponse)
    
                    // Combine signer respose and request data
                    if #available(iOS 11.0, *) {
                        encoder.outputFormatting = .sortedKeys
                    } else {
                        // Fallback on earlier versions
                    }
                    let newData = try! encoder.encode(keyassignRequest)
                    self.logger.trace("KeyAssign: requestToKeyAssign: ", String(decoding: newData, as: UTF8.self))
                    
                    let request = self.makeUrlRequest(url: endpoint)
                    return URLSession.shared.uploadTask(.promise, with: request, from: newData)
                }.done{ data, response in
                    self.logger.trace("KeyAssign: responseFromKeyAssignAPI: ", String(decoding: data, as: UTF8.self))
                    // let jsonData = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                    let decodedData = try! JSONDecoder().decode(JSONRPCresponse.self, from: data) // User decoder to covert to struct
                    self.logger.debug("keyAssign: fullfill: ", decodedData)
                    if(!tempPromise.isFulfilled){
                        seal.fulfill(decodedData)
                    }
                    // semaphore.signal() // Signal to start again
                }.catch{ err in
                    self.logger.error("KeyAssign: err: ",err)
                    // Reject only if reached the last point
                    if(i+1==endpoint.count) {
                        seal.reject(err)
                    }
                    // Signal to start again
                    semaphore.signal()
                }
                
            }
        }
        return tempPromise
        
    }
    
    // MARK:- Helper functions
    
    public func privateKeyToAddress(key: Data) -> Data{
        print(key)
        let publicKey = SECP256K1.privateToPublic(privateKey: key)!
        let address = Data(publicKey.sha3(.keccak256).suffix(20))
        return address
    }
    
    public func publicKeyToAddress(key: Data) -> Data{
        return Data(key.sha3(.keccak256).suffix(20))
    }
    
    public func publicKeyToAddress(key: String) -> String{
        return String(key.sha3(.keccak256).suffix(20))
    }
    
    func combinePublicKeys(keys: [String], compressed: Bool) -> String{
        let data = keys.map({ return Data(hex: $0)})
        let added = SECP256K1.combineSerializedPublicKeys(keys: data)
        return (added?.toHexString())!
    }

    func privateKeyToPublicKey4(privateKey: Data) -> secp256k1_pubkey? {
        if (privateKey.count != 32) {return nil}
        var publicKey = secp256k1_pubkey()
        let result = privateKey.withUnsafeBytes { (a: UnsafeRawBufferPointer) -> Int32? in
            if let pkRawPointer = a.baseAddress, a.count > 0 {
                let privateKeyPointer = pkRawPointer.assumingMemoryBound(to: UInt8.self)
                let res = secp256k1_ec_pubkey_create(TorusUtils.context!, UnsafeMutablePointer<secp256k1_pubkey>(&publicKey), privateKeyPointer)
                return res
            } else {
                return nil
            }
        }
        guard let res = result, res != 0 else {
            return nil
        }
        return publicKey
    }
    
    func tupleToArray(_ tuple: Any) -> [UInt8] {
        // var result = [UInt8]()
        let tupleMirror = Mirror(reflecting: tuple)
        let tupleElements = tupleMirror.children.map({ $0.value as! UInt8 })
        return tupleElements
    }
    
    func array32toTuple(_ arr: Array<UInt8>) -> (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8){
        return (arr[0] as UInt8, arr[1] as UInt8, arr[2] as UInt8, arr[3] as UInt8, arr[4] as UInt8, arr[5] as UInt8, arr[6] as UInt8, arr[7] as UInt8, arr[8] as UInt8, arr[9] as UInt8, arr[10] as UInt8, arr[11] as UInt8, arr[12] as UInt8, arr[13] as UInt8, arr[14] as UInt8, arr[15] as UInt8, arr[16] as UInt8, arr[17] as UInt8, arr[18] as UInt8, arr[19] as UInt8, arr[20] as UInt8, arr[21] as UInt8, arr[22] as UInt8, arr[23] as UInt8, arr[24] as UInt8, arr[25] as UInt8, arr[26] as UInt8, arr[27] as UInt8, arr[28] as UInt8, arr[29] as UInt8, arr[30] as UInt8, arr[31] as UInt8, arr[32] as UInt8, arr[33] as UInt8, arr[34] as UInt8, arr[35] as UInt8, arr[36] as UInt8, arr[37] as UInt8, arr[38] as UInt8, arr[39] as UInt8, arr[40] as UInt8, arr[41] as UInt8, arr[42] as UInt8, arr[43] as UInt8, arr[44] as UInt8, arr[45] as UInt8, arr[46] as UInt8, arr[47] as UInt8, arr[48] as UInt8, arr[49] as UInt8, arr[50] as UInt8, arr[51] as UInt8, arr[52] as UInt8, arr[53] as UInt8, arr[54] as UInt8, arr[55] as UInt8, arr[56] as UInt8, arr[57] as UInt8, arr[58] as UInt8, arr[59] as UInt8, arr[60] as UInt8, arr[61] as UInt8, arr[62] as UInt8, arr[63] as UInt8)
    }
    
}

// Necessary for decryption

extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    func strip04Prefix() -> String {
        if self.hasPrefix("04") {
            let indexStart = self.index(self.startIndex, offsetBy: 2)
            return String(self[indexStart...])
        }
        return self
    }
    
    func strip0xPrefix() -> String {
        if self.hasPrefix("0x") {
            let indexStart = self.index(self.startIndex, offsetBy: 2)
            return String(self[indexStart...])
        }
        return self
    }
    
    func addLeading0sForLength64() -> String{
        if self.count < 64 {
            let toAdd = String(repeating: "0", count: 64 - self.count)
            return toAdd + self
        }else {
            return self
        }
        // String(format: "%064d", self)
    }
}

extension StringProtocol {
    var hexa: [UInt8] {
        var startIndex = self.startIndex
        //print(startIndex, count)
        return (0..<count/2).compactMap { _ in
            let endIndex = index(after: startIndex)
            defer { startIndex = index(after: endIndex) }
            // print(startIndex, endIndex)
            return UInt8(self[startIndex...endIndex], radix: 16)
        }
    }
}

extension Sequence where Element == UInt8 {
    var data: Data { .init(self) }
    var hexa: String { map { .init(format: "%02x", $0) }.joined() }
}

extension Data {
    init?(hexString: String) {
        let length = hexString.count / 2
        var data = Data(capacity: length)
        for i in 0 ..< length {
            let j = hexString.index(hexString.startIndex, offsetBy: i * 2)
            let k = hexString.index(j, offsetBy: 2)
            let bytes = hexString[j..<k]
            if var byte = UInt8(bytes, radix: 16) {
                data.append(&byte, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }
    
    func addLeading0sForLength64() -> Data{
        Data(hex: self.toHexString().addLeading0sForLength64())
    }
}

