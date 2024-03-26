import CustomAuth
import FetchNodeDetails
import Foundation
import OSLog
import TorusUtils
import XCTest
import CommonSources

final class StubURLProtocolTests: XCTestCase {}

public class StubMockTorusUtils: TorusUtils {
    override open func getTimestamp() -> TimeInterval {
        let ret = 0.0
        print("[StubMockTorusUtils] getTimeStamp(): ", ret)
        return ret
    }

    open func generatePrivateKeyData() -> Data? {
        let ret = Data(base64Encoded: "FBz7bssmbsV6jBWoOJpkVOu14+6/Xgyt1pxTycODG08=")

        print("[StubMockTorusUtils] generatePrivateKeyData(): ", ret!.bytes.toBase64())
        return ret
    }
}

public class StubMockCASDKFactory: CASDKFactoryProtocol {
    public func createTorusUtils(loglevel: OSLogType, urlSession: URLSession, enableOneKey: Bool, network: TorusNetwork) -> AbstractTorusUtils {
        let allowHost = network.signerMap.appending("/api/allow")
        let signerHost = network.signerMap.appending("/api/sign")
        return StubMockTorusUtils(loglevel: loglevel, urlSession: urlSession, enableOneKey: enableOneKey, signerHost: signerHost, allowHost: allowHost, clientId: "Your Client ID")
    }

    public init() {
    }
}
