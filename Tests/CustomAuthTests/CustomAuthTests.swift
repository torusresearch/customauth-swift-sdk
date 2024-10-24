import Foundation
import JWTDecode
import XCTest

final class CustomAuthTests: XCTestCase {
    func test_jwtDecodeTest() {
        let idToken = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3RvcnVzLmF1LmF1dGgwLmNvbS8iLCJhdWQiOiJLRzd6azg5WDNRZ3R0U3lYOU5KNGZHRXlGTmhPY0pUdyIsIm5hbWUiOiJkaHJ1dkB0b3IudXMiLCJlbWFpbCI6ImRocnV2QHRvci51cyIsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwiLCJpYXQiOjE2NTQ2NzcwMTQsImVhdCI6MTY1NDY3NzMxNCwiZXhwIjoxNjU0Njc3MzE0fQ.3nzDGeSiQwfTVmL4T4-e5N19eD280GjtosFzcGjhWv_sUCV2YkM3i7iFIpUq7AxoPXjai5v7GTTPRu1zHPL6bg"
        let _ = try! decode(jwt: idToken)
    }
}
