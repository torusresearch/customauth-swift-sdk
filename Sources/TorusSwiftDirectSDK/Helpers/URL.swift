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
        self.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}

