import CustomAuth
import FetchNodeDetails
import Foundation
import OSLog
import TorusUtils
import XCTest

final class StubURLProtocolTests: XCTestCase {}

public class StubMockTorusUtils: TorusUtils {
    override open func getTimestamp() -> TimeInterval {
        let ret = 0.0
        print("[StubMockTorusUtils] getTimeStamp(): ", ret)
        return ret
    }

    open func generatePrivateKeyData() -> Data? {
        let ret = Data(base64Encoded: "FBz7bssmbsV6jBWoOJpkVOu14+6/Xgyt1pxTycODG08=")
        return ret
    }
}

public class StubMockCASDKFactory: CASDKFactoryProtocol {
    public func createTorusUtils(loglevel: OSLogType, urlSession: URLSession, enableOneKey: Bool, network: TorusNetwork) -> AbstractTorusUtils {
        return StubMockTorusUtils(loglevel: loglevel, urlSession: urlSession, enableOneKey: enableOneKey, network: .sapphire(.SAPPHIRE_DEVNET), clientId: "Your Client ID")
    }

    public init() {
    }
}
