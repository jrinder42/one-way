import XCTest
@testable import SyncOneWay

final class RcloneWrapperTests: XCTestCase {
    var wrapper: RcloneWrapper!
    var mockRunner: MockProcessRunner!
    
    override func setUp() {
        super.setUp()
        mockRunner = MockProcessRunner()
        wrapper = RcloneWrapper(processRunner: mockRunner)
    }
    
    func testIsRcloneAvailableReturnsTrueWhenProcessSucceeds() async {
        mockRunner.shouldSucceed = true
        
        let available = await wrapper.isRcloneAvailable()
        
        XCTAssertTrue(available)
        XCTAssertNotNil(mockRunner.executedExecutableURL)
        XCTAssertEqual(mockRunner.executedArguments, ["--version"])
    }
    
    func testIsRcloneAvailableReturnsFalseWhenProcessFails() async {
        mockRunner.shouldSucceed = false
        mockRunner.exitStatus = 1
        
        let available = await wrapper.isRcloneAvailable()
        
        XCTAssertFalse(available)
    }
}
