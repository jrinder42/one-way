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
    
    func testSyncCallsRcloneCopyWhenDeleteFilesIsFalse() async throws {
        mockRunner.shouldSucceed = true
        
        try await wrapper.sync(
            source: "/src/",
            destination: "dest/",
            remoteName: "gdrive",
            deleteFiles: false
        )
        
        XCTAssertEqual(mockRunner.executedArguments?[0], "copy")
        XCTAssertEqual(mockRunner.executedArguments?.contains("/src/"), true)
        XCTAssertEqual(mockRunner.executedArguments?.contains("gdrive:dest/"), true)
    }
    
    func testSyncCallsRcloneSyncWhenDeleteFilesIsTrue() async throws {
        mockRunner.shouldSucceed = true
        
        try await wrapper.sync(
            source: "/src/",
            destination: "dest/",
            remoteName: "gdrive",
            deleteFiles: true
        )
        
        XCTAssertEqual(mockRunner.executedArguments?[0], "sync")
        XCTAssertEqual(mockRunner.executedArguments?.contains("/src/"), true)
        XCTAssertEqual(mockRunner.executedArguments?.contains("gdrive:dest/"), true)
    }
    
    func testSyncIncludesBandwidthLimitIfProvided() async throws {
        mockRunner.shouldSucceed = true
        
        try await wrapper.sync(
            source: "/src/",
            destination: "dest/",
            remoteName: "gdrive",
            bandwidthLimit: "1M"
        )
        
        XCTAssertEqual(mockRunner.executedArguments?.contains("--bwlimit"), true)
        XCTAssertEqual(mockRunner.executedArguments?.contains("1M"), true)
    }
    
    func testSyncIncludesProgressFlag() async throws {
        mockRunner.shouldSucceed = true
        
        try await wrapper.sync(
            source: "/src/",
            destination: "dest/",
            remoteName: "gdrive"
        )
        
        XCTAssertEqual(mockRunner.executedArguments?.contains("-P"), true)
    }
}
