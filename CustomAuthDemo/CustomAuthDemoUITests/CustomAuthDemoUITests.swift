import XCTest
import CustomAuthDemo

class CustomAuthDemoUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    func testExample() throws {

    }

    func testLaunchPerformance() throws {
            measure(metrics: [XCTApplicationLaunchMetric.init()]) {
                XCUIApplication().launch()
            }
    }
}
