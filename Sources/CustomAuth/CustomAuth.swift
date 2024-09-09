import FetchNodeDetails
import Foundation
import OSLog
import TorusUtils
#if canImport(curveSecp256k1)
    import curveSecp256k1
#endif

public class CustomAuth {
    public let isInitialized: Bool = false

    public let config: CustomAuthArgs

    public let torus: TorusUtils

    public let nodeDetailManager: NodeDetailManager

    /// Initializes CustomAuth with the provided options
    ///
    /// - Parameters:
    ///   - params: `CustomAuthArgs`
    ///
    /// - Returns: `CustomAuth`
    ///
    /// - Throws: `CASDKError.invalidCallbackURLScheme`,  `TorusUtilError.invalidInput`
    public init(config: CustomAuthArgs) throws {
        if URL(string: config.urlScheme)?.scheme == nil {
            throw CASDKError.invalidCallbackURLScheme
        }
        
        self.config = config

        let nodeDetails = NodeDetailManager(network: config.network)
        nodeDetailManager = nodeDetails

        let torusOptions = TorusOptions(
            clientId: config.web3AuthClientId,
            network: config.network,
            legacyMetadataHost: config.metadataUrl,
            serverTimeOffset: config.serverTimeOffset,
            enableOneKey: config.enableOneKey)
        let torusUtils = try TorusUtils(params: torusOptions)
        torus = torusUtils

        torus.setApiKey(apiKey: config.apiKey)
    }

    /// Initiates a login using a single verifier
    ///
    /// - Parameters:
    ///   - params: `SingleLoginParams`
    ///
    /// - Returns: `TorusLoginResponse`
    ///
    /// - Throws: `CASDKError`,  `TorusUtilError`
    public func triggerLogin(args: SingleLoginParams) async throws -> TorusLoginResponse {
        let loginHandler = try HandlerFactory.createHandler(params: CreateHandlerParams(typeOfLogin: args.typeOfLogin, verifier: args.verifier, clientId: args.clientId, urlScheme: config.urlScheme, redirectURL: args.redirectURL, jwtParams: args.jwtParams, customState: args.customState))

        var loginParams: LoginWindowResponse
        if args.hash != nil && args.queryParams != nil {
            let (error, hashParams, instanceParams) = try handleRedirectParameters(hash: args.hash!, queryParameters: args.queryParams!)
            if !error.isEmpty {
                throw CASDKError.redirectParamsError(msg: error)
            }
            loginParams = LoginWindowResponse(accessToken: hashParams.params["access_token"], idToken: hashParams.params["idToken"], ref: hashParams.params["ref"] ?? "", extraParams: hashParams.params["extra_params"], extraParamsPassed: hashParams.params["extra_params_passed"]!, state: instanceParams)
        } else {
            loginParams = try await loginHandler.handleLoginWindow(popupFeatures: config.popupFeatures)
        }

        let userInfo = try await loginHandler.getUserInfo(params: loginParams, storageServerUrl: nil)

        let verifyParams: VerifierParams = VerifierParams(verifier_id: userInfo.verifierId)

        let torusKey = try await getTorusKey(verifier: userInfo.verifier, verifier_id: userInfo.verifierId, verifierParams: verifyParams, idToken: loginParams.idToken ?? loginParams.accessToken ?? "")

        let returnedInfo = UserInfo(email: userInfo.email, name: userInfo.name, profileImage: userInfo.profileImage, aggregateVerifier: userInfo.aggregateVerifier, verifier: userInfo.verifier, verifierId: userInfo.verifierId, typeOfLogin: userInfo.typeOfLogin, ref: userInfo.ref, //extraVerifierParams: userInfo.extraVerifierParams,
            accessToken: loginParams.accessToken, idToken: loginParams.idToken, extraParams: loginParams.extraParams, extraParamsPassed: loginParams.extraParamsPassed, state: loginParams.state)

        return TorusLoginResponse(singleVerifierResponse: TorusSingleVerifierResponse(userInfo: returnedInfo, loginResponse: loginParams), torusKey: torusKey)
    }

    /// Initiates a login using a aggregate verifier
    ///
    /// - Parameters:
    ///   - params: `AggregateLoginParams`
    ///
    /// - Returns: `TorusAggregateLoginResponse`
    ///
    /// - Throws: `CASDKError`,  `TorusUtilError`
    public func triggerAggregateLogin(args: AggregateLoginParams) async throws -> TorusAggregateLoginResponse {
        if args.subVerifierDetailsArray.isEmpty {
            throw CASDKError.invalidParameters
        }
        if args.subVerifierDetailsArray.count != 1 && args.aggregateVerifierType == AggregateVerifierType.single_id_verifier {
            throw CASDKError.invalidParameters
        }

        var loginParamsArray: [LoginWindowResponse] = []
        var userInfoArray: [UserInfo] = []
        for subverifierDetail in args.subVerifierDetailsArray {
            let loginHandler = try HandlerFactory.createHandler(params: CreateHandlerParams(typeOfLogin: subverifierDetail.typeOfLogin, verifier: subverifierDetail.verifier, clientId: subverifierDetail.clientId, urlScheme: config.urlScheme, redirectURL: subverifierDetail.redirectURL, jwtParams: subverifierDetail.jwtParams, customState: subverifierDetail.customState))
            var loginParams: LoginWindowResponse
            var userInfo: UserInfo
            if subverifierDetail.hash != nil && subverifierDetail.queryParams != nil {
                let (error, hashParams, instanceParams) = try handleRedirectParameters(hash: subverifierDetail.hash!, queryParameters: subverifierDetail.queryParams!)
                if !error.isEmpty {
                    throw CASDKError.redirectParamsError(msg: error)
                }
                loginParams = LoginWindowResponse(accessToken: hashParams.params["access_token"], idToken: hashParams.params["idToken"], ref: hashParams.params["ref"] ?? "", extraParams: hashParams.params["extra_params"], extraParamsPassed: hashParams.params["extra_params_passed"]!, state: instanceParams)
            } else {
                loginParams = try await loginHandler.handleLoginWindow(popupFeatures: config.popupFeatures)
            }

            let info = try await loginHandler.getUserInfo(params: loginParams, storageServerUrl: nil)
            userInfo = UserInfo(email: info.email, name: info.name, profileImage: info.profileImage, aggregateVerifier: args.verifierIdentifier, verifier: info.verifier, verifierId: info.verifierId, typeOfLogin: info.typeOfLogin, ref: info.ref, //extraVerifierParams: info.extraVerifierParams,
                accessToken: loginParams.accessToken, idToken: loginParams.idToken, extraParams: loginParams.extraParams, extraParamsPassed: loginParams.extraParamsPassed, state: loginParams.state)
            loginParamsArray.append(loginParams)
            userInfoArray.append(userInfo)
        }

        var subVerifierIds: [String] = []
        var aggregateVerifierParams: [VerifyParams] = []
        var aggregateIdTokenSeeds: [String] = []
        var aggregateVerifierId: String = ""

        for i in 0 ..< args.subVerifierDetailsArray.count {
            let loginParams = loginParamsArray[i]
            let userInfo = userInfoArray[i]

            aggregateVerifierParams.append(VerifyParams(verifier_id: userInfo.verifierId, idtoken: loginParams.idToken ?? loginParams.accessToken!))
            aggregateIdTokenSeeds.append(loginParams.idToken ?? loginParams.accessToken!)
            subVerifierIds.append(userInfo.verifier)
            aggregateVerifierId = userInfo.verifierId
        }
        aggregateIdTokenSeeds.sort()
        let joined = aggregateIdTokenSeeds.joined(separator: "\u{29}").data(using: .utf8)!
        let aggregateIdToken = try keccak256(data: joined).hexString
        let aggregateParams: VerifierParams = VerifierParams(verifier_id: aggregateVerifierId, extended_verifier_id: nil, sub_verifier_ids: subVerifierIds, verify_params: aggregateVerifierParams)

        let aggregateTorusKey = try await getTorusKey(verifier: args.verifierIdentifier, verifier_id: aggregateVerifierId, verifierParams: aggregateParams, idToken: aggregateIdToken)

        var aggregateVerifierResponses: [TorusAggregateVerifierResponse] = []
        for i in 0 ..< userInfoArray.count {
            let loginParams = loginParamsArray[i]
            let userInfo = userInfoArray[i]
            aggregateVerifierResponses.append(TorusAggregateVerifierResponse(userInfo: userInfo, loginResponse: loginParams))
        }

        return TorusAggregateLoginResponse(torusAggregateVerifierResponse: aggregateVerifierResponses, torusKey: aggregateTorusKey)
    }

    /// Initiates a login using a hybrid verifier
    ///
    /// - Parameters:
    ///   - params: `HybridAggregateLoginParams`
    ///
    /// - Returns: `TorusHybridAggregateLoginResponse`
    ///
    /// - Throws: `CASDKError`,  `TorusUtilError`
    public func triggerHybridAggregateLogin(args: HybridAggregateLoginParams) async throws -> TorusHybridAggregateLoginResponse {
        if args.aggregateLoginParams.subVerifierDetailsArray.isEmpty {
            throw CASDKError.invalidParameters
        }
        if args.aggregateLoginParams.subVerifierDetailsArray.count == 1 && args.aggregateLoginParams.aggregateVerifierType == AggregateVerifierType.single_id_verifier {
            throw CASDKError.invalidParameters
        }

        let loginHandler = try HandlerFactory.createHandler(params: CreateHandlerParams(typeOfLogin: args.singleLogin.typeOfLogin, verifier: args.singleLogin.verifier, clientId: args.singleLogin.clientId, urlScheme: config.urlScheme, redirectURL: args.singleLogin.redirectURL, jwtParams: args.singleLogin.jwtParams, customState: args.singleLogin.customState))

        var loginParams: LoginWindowResponse
        if args.singleLogin.hash != nil && args.singleLogin.queryParams != nil {
            let (error, hashParams, instanceParams) = try handleRedirectParameters(hash: args.singleLogin.hash!, queryParameters: args.singleLogin.queryParams!)
            if !error.isEmpty {
                throw CASDKError.redirectParamsError(msg: error)
            }
            loginParams = LoginWindowResponse(accessToken: hashParams.params["access_token"], idToken: hashParams.params["idToken"], ref: hashParams.params["ref"] ?? "", extraParams: hashParams.params["extra_params"], extraParamsPassed: hashParams.params["extra_params_passed"]!, state: instanceParams)
        } else {
            loginParams = try await loginHandler.handleLoginWindow(popupFeatures: config.popupFeatures)
        }

        let userInfo = try await loginHandler.getUserInfo(params: loginParams, storageServerUrl: nil)

        let verifyParams: VerifierParams = VerifierParams(verifier_id: userInfo.verifierId)

        let torusKey = try await getTorusKey(verifier: userInfo.verifier, verifier_id: userInfo.verifierId, verifierParams: verifyParams, idToken: loginParams.idToken!)

        let returnedInfo = UserInfo(email: userInfo.email, name: userInfo.name, profileImage: userInfo.profileImage, aggregateVerifier: userInfo.aggregateVerifier, verifier: userInfo.verifier, verifierId: userInfo.verifierId, typeOfLogin: userInfo.typeOfLogin, ref: userInfo.ref, // extraVerifierParams: userInfo.extraVerifierParams,
            accessToken: loginParams.accessToken, idToken: loginParams.idToken, extraParams: loginParams.extraParams, extraParamsPassed: loginParams.extraParamsPassed, state: loginParams.state)

        var subVerifierIds: [String] = []
        var aggregateVerifierParams: [VerifyParams] = []
        var aggregateIdTokenSeeds: [String] = []
        var aggregateVerifierId: String = ""
        for i in 0 ..< args.aggregateLoginParams.subVerifierDetailsArray.count {
            let sub = args.aggregateLoginParams.subVerifierDetailsArray[i]
            aggregateVerifierParams.append(VerifyParams(verifier_id: userInfo.verifierId, idtoken: loginParams.idToken!))
            aggregateIdTokenSeeds.append(loginParams.idToken ?? loginParams.accessToken!)
            subVerifierIds.append(sub.verifier)
            aggregateVerifierId = userInfo.verifierId
        }
        aggregateIdTokenSeeds.sort()
        let joined = aggregateIdTokenSeeds.joined(separator: "\u{29}").data(using: .utf8)!
        let aggregateIdToken = try keccak256(data: joined)
        let aggregateParams: VerifierParams = VerifierParams(verifier_id: aggregateVerifierId, extended_verifier_id: nil, sub_verifier_ids: subVerifierIds, verify_params: aggregateVerifierParams)

        let aggregateTorusKey = try await getTorusKey(verifier: args.aggregateLoginParams.verifierIdentifier, verifier_id: aggregateVerifierId, verifierParams: aggregateParams, idToken: String(data: aggregateIdToken, encoding: .utf8)!)

        let aggregateResponse = TorusAggregateVerifierResponse(userInfo: returnedInfo, loginResponse: loginParams)

        let aggregateLogin = TorusAggregateLoginResponse(torusAggregateVerifierResponse: [aggregateResponse], torusKey: torusKey)

        return TorusHybridAggregateLoginResponse(singleLogin: aggregateLogin, aggregateLogins: [aggregateTorusKey])
    }

    /// Retrieves the key details
    ///
    /// - Parameters:
    ///   - verifier: `String`
    ///   - verifierParams: `VerifierParams`
    ///   - idToken: `String`
    ///
    /// - Returns: `TorusKey`
    ///
    /// - Throws: `CASDKError`,  `TorusUtilError`, `FetchNodeError`
    func getTorusKey(verifier: String, verifier_id: String, verifierParams: VerifierParams, idToken: String, extraParams: TorusUtilsExtraParams? = nil) async throws -> TorusKey {
        let nodeDetails = try await nodeDetailManager.getNodeDetails(verifier: verifier, verifierID: verifier_id)

        return try await torus.retrieveShares(endpoints: nodeDetails.getTorusNodeEndpoints(), verifier: verifier, verifierParams: verifierParams, idToken: idToken)
    }

    /// Retrieves the aggregate key details
    ///
    /// - Parameters:
    ///   - verifier: `String`
    ///   - verifierParams: `VerifierParams`
    ///   - subVerifierInfoArray: `TorusSubVerifierInfo`
    ///
    /// - Returns: `TorusKey`
    ///
    /// - Throws: `CASDKError`,  `TorusUtilError`, `FetchNodeError`
    func getAggregateTorusKey(verifier: String, verifierParams: VerifierParams, subVerifierInfoArray: [TorusSubVerifierInfo]) async throws -> TorusKey {
        let nodeDetails = try await nodeDetailManager.getNodeDetails(verifier: verifier, verifierID: verifierParams.verifier_id)

        var aggregateIdTokenSeeds: [String] = []
        var subVerifierIds: [String] = []

        var verifyParams: [VerifyParams] = []
        for i in 0 ..< subVerifierInfoArray.count {
            let userInfo = subVerifierInfoArray[i]
            verifyParams.append(VerifyParams(verifier_id: verifierParams.verifier_id, idtoken: userInfo.idToken))
            subVerifierIds.append(userInfo.verifier)
            aggregateIdTokenSeeds.append(userInfo.idToken)
        }

        aggregateIdTokenSeeds.sort()
        let joined = aggregateIdTokenSeeds.joined(separator: "\u{29}").data(using: .utf8)!
        let aggregateIdToken = try keccak256(data: joined)
        let params: VerifierParams = VerifierParams(verifier_id: verifierParams.verifier_id, extended_verifier_id: verifierParams.extended_verifier_id, sub_verifier_ids: subVerifierIds, verify_params: verifyParams)

        return try await torus.retrieveShares(endpoints: nodeDetails.getTorusNodeEndpoints(), verifier: verifier, verifierParams: params, idToken: String(data: aggregateIdToken, encoding: .utf8)!)
    }
}
