import XCTest
@testable import RJSecurity

final class RJSecurityTests: XCTestCase {
    
    func testSampleUsage1() {
        XCTAssert(CryptoKit.sampleUsage1())
    }
    
    func testSampleUsage2() {
        XCTAssert(CryptoKit.sampleUsage2())
    }
    
    func testSymetricKeysGeneration() {
        XCTAssert(CryptoKit.testSymetricKeysGeneration())
    }
    
    func testPublicKeyToBase64AndThenBackToPublicKey() {
        XCTAssert(CryptoKit.testPublicKeyToBase64AndThenBackToPublicKey())
    }
    
    static var allTests = [
        ("testSampleUsage1", testSampleUsage1),
        ("testSampleUsage2", testSampleUsage2),
        ("testSymetricKeysGeneration", testSymetricKeysGeneration),
        ("testPublicKeyToBase64AndThenBackToPublicKey", testPublicKeyToBase64AndThenBackToPublicKey),
    ]
}
