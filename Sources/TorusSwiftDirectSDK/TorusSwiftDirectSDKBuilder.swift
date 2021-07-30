import Foundation
import BestLogger
import FetchNodeDetails

@available(iOS 11.0, *)
public class TorusSwiftDirectSDKBuilder {
    let aggregateVerifierType: verifierTypes
    let aggregateVerifierName: String
    var subVerifierDetails: [SubVerifierDetails]
    var network: EthereumNetwork = .ROPSTEN
    var loglevel: BestLogger.Level = .none
    var torusUtils: AbstractTorusUtils = MainTorusUtils()
    
    public init(verifierType: verifierTypes, verfierName: String) {
        self.aggregateVerifierType = verifierType
        self.aggregateVerifierName = verfierName
        self.subVerifierDetails = []
    }
    
    public func withSubVerifierDetails(_ subVerifierDetails: [SubVerifierDetails]) -> TorusSwiftDirectSDKBuilder {
        self.subVerifierDetails = subVerifierDetails
        return self
    }
    
    public func withNetwork(_ network: EthereumNetwork) -> TorusSwiftDirectSDKBuilder {
        self.network = network
        return self
    }
    
    public func withLoglevel(_ loglevel: BestLogger.Level) -> TorusSwiftDirectSDKBuilder {
        self.loglevel = loglevel
        return self
    }
    
    public func withTorusUtils(_ torusUtils: AbstractTorusUtils) -> TorusSwiftDirectSDKBuilder {
        self.torusUtils = torusUtils
        return self
    }
    
    public func build() -> TorusSwiftDirectSDK {
        return TorusSwiftDirectSDK(
            aggregateVerifierType: self.aggregateVerifierType,
            aggregateVerifierName: self.aggregateVerifierName,
            subVerifierDetails: self.subVerifierDetails,
            network: self.network,
            loglevel: self.loglevel,
            torusUtils: self.torusUtils)
    }
}
