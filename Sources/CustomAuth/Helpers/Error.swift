public enum CASDKError: Error {
    case decodingFailed
    case encodingFailed
    case accessTokenNotProvided
    case idTokenNotProvided
    case invalidParameters
    case invalidCallbackURLScheme
    case invalidAuth0Options
    case invalidVerifier
    case invalidClientID
    case invalidMethod(msg: String)
    case redirectParamsError(msg: String)

    public var errorDescription: String {
        switch self {
        case .decodingFailed:
            return "decoding failed"
        case .encodingFailed:
            return "encoding failed"
        case .accessTokenNotProvided:
            return "access token not provided"
        case .idTokenNotProvided:
            return "id token not provided"
        case .invalidCallbackURLScheme:
            return "callback scheme is invalid"
        case .invalidParameters:
            return "parameters are missing or invalid"
        case .invalidAuth0Options:
            return "auth0 options are missing or invalid"
        case .invalidMethod(msg: let msg):
            return msg
        case .redirectParamsError(msg: let msg):
            return msg
        case .invalidVerifier:
            return "invalid verifier"
        case .invalidClientID:
            return "invalid client ID"
        }
    }
}
