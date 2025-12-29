import XCTest
import SwiftUI
@testable import SyncOneWay

final class SyncOneWayTests: XCTestCase {
    func testAppStructureExists() {
        // Verify that the App struct exists and can be instantiated
        let app = SyncOneWayApp()
        XCTAssertNotNil(app)
        
        // Basic check to ensure body property is accessible (though we can't easily inspect SwiftUI body content in unit tests)
        XCTAssertNotNil(app.body)
    }
}
