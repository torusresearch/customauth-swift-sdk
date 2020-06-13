public enum Web3Error: Error {
    case transactionSerializationError
    case connectionError
    case dataError
    case walletError
    case inputError(desc:String)
    case nodeError(desc:String)
    case processingError(desc:String)
    case generalError(err:Error)
    case unknownError
    
    public var errorDescription: String {
        switch self {
            
        case .transactionSerializationError:
            return "Transaction Serialization Error"
        case .connectionError:
            return "Connection Error"
        case .dataError:
            return "Data Error"
        case .walletError:
            return "Wallet Error"
        case .inputError(let desc):
            return desc
        case .nodeError(let desc):
            return desc
        case .processingError(let desc):
            return desc
        case .generalError(let err):
            return err.localizedDescription
        case .unknownError:
            return "Unknown Error"
        }
    }
}
