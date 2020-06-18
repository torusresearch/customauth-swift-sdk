public enum TSDSError: Error {
    case getUserInfoFailed
    case decodingFailed
    case accessTokenAPIFailed
    case accessTokenNotProvided
    case authGrantNotProvided
    case idTokenFailed
    case unknownError
    case methodUnavailable
    
    public var errorDescription: String {
        switch self {
        case .getUserInfoFailed:
            return "Unable to get verifier ID"
        case .decodingFailed:
            return "decodingFailed"
        case .accessTokenAPIFailed:
            return "API failed for retrieving access token"
        case .accessTokenNotProvided:
            return "access token unavailable in data"
        case .authGrantNotProvided:
            return "authorization grant not available"
        case .idTokenFailed:
            return "idTokenFailed"
        case .unknownError:
            return "unknownError"
        case .methodUnavailable:
            return "method unavailable/unimplemented"
        }
    }
}
