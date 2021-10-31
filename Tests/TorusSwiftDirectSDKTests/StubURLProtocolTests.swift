//
//  File.swift
//  
//
//  Created by Michael Lee on 31/10/2021.
//

import Foundation
import XCTest
import PromiseKit

@available(iOS 13.0, *)
final class StubURLProtocolTests: XCTestCase {
    func testStubURLProtocol() {
        let expectation1 = XCTestExpectation(description: "StubURLProtocol should response to correct request without body")
        let expectation2 = XCTestExpectation(description: "StubURLProtocol should response to correct request with body")
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [StubURLProtocol.self]
        let session = URLSession.init(configuration: sessionConfiguration)
        
        var req1 = URLRequest(url: URL(string: "http://abc.com/1")!)
        req1.setValue("efg", forHTTPHeaderField: "abc")
        req1.httpMethod = "GET"
        session.dataTask(.promise, with: req1).done { data, res in
            let httpRes = res as! HTTPURLResponse
            XCTAssertEqual(httpRes.value(forHTTPHeaderField: "abc"), "efg")
            XCTAssertEqual(httpRes.statusCode, 200)
            XCTAssertEqual(data, Data(#"{"abc":"efg"}"#.utf8))
        }.catch { err in
            XCTFail(err.localizedDescription)
        }.finally {
            expectation1.fulfill()
        }
        
        var req2 = URLRequest(url: URL(string: "http://abcd.com/2")!)
        req2.setValue("efg", forHTTPHeaderField: "abc")
        req2.httpMethod = "POST"
        req2.httpBody = Data(#"{"abc":"efg"}"#.utf8)
        session.dataTask(.promise, with: req2).done { data, res in
            let httpRes = res as! HTTPURLResponse
            XCTAssertEqual(httpRes.value(forHTTPHeaderField: "abc"), "efg")
            XCTAssertEqual(httpRes.statusCode, 200)
            XCTAssertEqual(data, Data(#"{"abc":"efg"}"#.utf8))
        }.catch { err in
            XCTFail(err.localizedDescription)
        }.finally {
            expectation2.fulfill()
        }
        
        wait(for: [expectation1, expectation2], timeout: 5)
    }
}
