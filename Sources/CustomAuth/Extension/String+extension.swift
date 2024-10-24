import Foundation

internal extension String {
    func fromBase64URL() throws -> String {
        var base64 = self
        base64 = base64.replacingOccurrences(of: "-", with: "+")
        base64 = base64.replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 {
            base64 = base64.appending("=")
        }
        guard let data = Data(base64Encoded: base64) else {
            throw CASDKError.decodingFailed
        }
        return String(data: data, encoding: .utf8)!
    }

    var parametersFromQueryString: [String: String] {
        return dictionaryBySplitting("&", keyValueSeparator: "=")
    }

    func dictionaryBySplitting(_ elementSeparator: String, keyValueSeparator: String) -> [String: String] {
        var string = self

        if hasPrefix(elementSeparator) {
            string = String(dropFirst(1))
        }

        var parameters = [String: String]()

        let scanner = Scanner(string: string)

        while !scanner.isAtEnd {
            let key = scanner.scanUpToString(keyValueSeparator)
            _ = scanner.scanString(keyValueSeparator)

            let value = scanner.scanUpToString(elementSeparator)
            _ = scanner.scanString(elementSeparator)

            if let key = key {
                if let value = value {
                    if key.contains(elementSeparator) {
                        var keys = key.components(separatedBy: elementSeparator)
                        if let key = keys.popLast() {
                            parameters.updateValue(value, forKey: String(key))
                        }
                        for flag in keys {
                            parameters.updateValue("", forKey: flag)
                        }
                    } else {
                        parameters.updateValue(value, forKey: key)
                    }
                } else {
                    parameters.updateValue("", forKey: key)
                }
            }
        }

        return parameters
    }
}
