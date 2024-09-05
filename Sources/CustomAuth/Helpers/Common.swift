import Foundation

internal func loginToConnection(loginType: LoginType) -> String {
    switch loginType {
    case .apple: break
    case .google: break
    case .facebook: break
    case .reddit: break
    case .twitch: break
    case .discord: break
    case .github: break
    case .linkedin: break
    case .twitter: break
    case .weibo: break
    case .line: break
    case .email_password: return "Username-Password-Authentication"
    case .passwordless: return "email"
    case .email_passwordless: return "email"
    case .sms_passwordless: return "sms"
    case .jwt: break
    }
    return loginType.rawValue
}

internal func caseSensitiveField(field: String, isCaseSensitive: Bool) -> String{
    return isCaseSensitive ? field : field.lowercased()
}

internal func getVerifierId(
    userInfo: Auth0UserInfo,
    typeOfLogin: LoginType,
    verifierIdField: String? = nil,
    isVerifierIdCaseSensitive: Bool = true
) throws -> String {
    let name = userInfo.name
    let sub = userInfo.sub

    let encoded = try JSONEncoder().encode(userInfo)
    let json = try JSONSerialization.jsonObject(with: encoded, options: []) as! [String: String]

    if verifierIdField != nil {
        return json[caseSensitiveField(field: verifierIdField!, isCaseSensitive: isVerifierIdCaseSensitive)]!
    }

    switch typeOfLogin {
        case .passwordless: return name
        case .email_password: return name
        case .email_passwordless: return name
        case .sms_passwordless: return caseSensitiveField(field: name, isCaseSensitive: isVerifierIdCaseSensitive)
        case .google: return sub
        case .facebook: return sub
        case .reddit: return sub
        case .twitch: return sub
        case .apple: return sub
        case .github: return sub
        case .discord: return sub
        case .linkedin: return sub
        case .twitter: return sub
        case .weibo: return sub
        case .line: return sub
        case .jwt: return caseSensitiveField(field: sub, isCaseSensitive: isVerifierIdCaseSensitive)
    }
}

func handleRedirectParameters(hash: String, queryParameters: TorusGenericContainer) throws -> (String, TorusGenericContainer, TorusGenericContainer) {
    var hashParams: [String: String] = [:]
    let hashSplit = hash.split(separator: "&")
    hashSplit.forEach({
        let paramSplit = $0.split(separator: "=")
        hashParams.updateValue(String(paramSplit[1]), forKey: String(paramSplit[0]))
    })

    var instanceParams: [String: String] = [:]
    var error = ""
    if hashParams.count > 0 && hashParams["state"] != nil {
        let instanceSplit = try hashParams["state"]!.fromBase64URL().split(separator: "&")
        instanceSplit.forEach({
            let paramSplit = $0.split(separator: "=")
            instanceParams.updateValue(String(paramSplit[1]), forKey: String(paramSplit[0]))
        })
        if hashParams["error_description"] != nil {
            error = hashParams["error_description"]!
        } else if hashParams["error"] != nil {
            error = hashParams["error"]!
        }
    } else if queryParameters.params.count > 0 && queryParameters.params["state"] != nil {
        let instanceSplit = try queryParameters.params["state"]!.fromBase64URL().split(separator: "&")
        instanceSplit.forEach({
            let paramSplit = $0.split(separator: "=")
            instanceParams.updateValue(String(paramSplit[1]), forKey: String(paramSplit[0]))
        })
        if queryParameters.params["error"] != nil {
            error = queryParameters.params["error"]!
        }
    }

    return (error, TorusGenericContainer(params: hashParams), TorusGenericContainer(params: instanceParams))
}

func parseURL(url: URL) -> [String: String] {
    var responseParameters = [String: String]()
    if let query = url.query {
        responseParameters.merge(query.parametersFromQueryString, uniquingKeysWith: { _, new in new })
    }
    if let fragment = url.fragment, !fragment.isEmpty {
        responseParameters.merge(fragment.parametersFromQueryString, uniquingKeysWith: { _, new in new })
    }
    return responseParameters
}

func makeUrlRequest(url: String, method: String) -> URLRequest {
    var rq = URLRequest(url: URL(string: url)!)
    rq.httpMethod = method
    rq.addValue("application/json", forHTTPHeaderField: "Content-Type")
    rq.addValue("application/json", forHTTPHeaderField: "Accept")
    return rq
}
