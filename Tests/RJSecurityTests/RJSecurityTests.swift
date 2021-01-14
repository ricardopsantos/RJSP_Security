import XCTest
@testable import RJSecurity

final class RJSecurityTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(RJSecurity().text, "my secret!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
