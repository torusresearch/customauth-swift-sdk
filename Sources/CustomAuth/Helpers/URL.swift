//
//  File.swift
//
//
//  Created by Shubham on 13/11/20.
//

import Foundation

func makeUrlRequest(url: String, method: String) -> URLRequest {
    var rq = URLRequest(url: URL(string: url)!)
    rq.httpMethod = method
    rq.addValue("application/json", forHTTPHeaderField: "Content-Type")
    rq.addValue("application/json", forHTTPHeaderField: "Accept")
    return rq
}

extension URLComponents {
    mutating func setQueryItems(with parameters: [String: String]) {
        queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}

extension URL {
    var queryDictionary: [String: String]? {
        guard let query = query else { return nil }

        var queryStrings = [String: String]()
        for pair in query.components(separatedBy: "&") {
            let key = pair.components(separatedBy: "=")[0]

            let value = pair
                .components(separatedBy: "=")[1]
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? ""

            queryStrings[key] = value
        }
        return queryStrings
    }
}

/*
Fix for the issue
 https://www.swiftbysundell.com/articles/making-async-system-apis-backward-compatible/
*/
@available(iOS, deprecated: 15.0, message: "Use the built-in API instead")
extension URLSession {
    func data(for request: URLRequest, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: request) { data, response, error in
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }

                continuation.resume(returning: (data, response))
            }

            task.resume()
        }
    }
}
