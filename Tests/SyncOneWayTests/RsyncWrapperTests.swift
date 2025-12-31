import XCTest
@testable import SyncOneWay

final class RsyncWrapperTests: XCTestCase {
    var wrapper: RsyncWrapper!
    var mockRunner: MockProcessRunner!
    
    override func setUp() {
        super.setUp()
        mockRunner = MockProcessRunner()
        wrapper = RsyncWrapper(processRunner: mockRunner)
    }
    
    func testSyncCommandConstructionWithDelete() async throws {
        let source = "/source/path/"
        let destination = "/destination/path/"
        
        mockRunner.shouldSucceed = true
        
        try await wrapper.sync(source: source, destination: destination, deleteFiles: true)
        
        XCTAssertEqual(mockRunner.executedExecutableURL?.path, "/usr/bin/rsync")
        XCTAssertEqual(mockRunner.executedArguments, ["-av", "--delete", source, destination])
    }
    
    func testSyncCommandConstructionWithoutDelete() async throws {
        let source = "/source/path/"
        let destination = "/destination/path/"
        
        mockRunner.shouldSucceed = true
        
        try await wrapper.sync(source: source, destination: destination, deleteFiles: false)
        
        XCTAssertEqual(mockRunner.executedExecutableURL?.path, "/usr/bin/rsync")
        XCTAssertEqual(mockRunner.executedArguments, ["-av", source, destination])
    }
    
    func testSyncFailureThrowsError() async {
        mockRunner.shouldSucceed = false
        mockRunner.exitStatus = 1
        
        do {
            try await wrapper.sync(source: "s", destination: "d")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
