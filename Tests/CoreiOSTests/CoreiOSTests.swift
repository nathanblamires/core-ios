import XCTest
@testable import CoreiOS

final class CoreiOSTests: XCTestCase {
    
    func testSafeSubscripting() {
        let items = ["Hello", "World"]
        let itemThatExists = items[safe: 1]
        let itemThatDoesntExists = items[safe: 2]
        XCTAssertEqual(itemThatExists, "World")
        XCTAssertEqual(itemThatDoesntExists, nil)
    }
    
    static var allTests = [
        ("testSafeSubscripting", testSafeSubscripting),
    ]
}
