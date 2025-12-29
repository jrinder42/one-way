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
    
    func testSyncCommandConstruction() async throws {
        let source = "/source/path/"
        let destination = "/destination/path/"
        
        mockRunner.shouldSucceed = true
        
        try await wrapper.sync(source: source, destination: destination)
        
        XCTAssertEqual(mockRunner.executedExecutableURL?.path, "/usr/bin/rsync")
        XCTAssertEqual(mockRunner.executedArguments, ["-av", "--delete", source, destination])
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

class MockProcessRunner: ProcessRunnerProtocol {
    var shouldSucceed = true
    var exitStatus: Int32 = 0
    
    var executedExecutableURL: URL?
    var executedArguments: [String]?
    
    func run(executableURL: URL, arguments: [String]) async throws -> Int32 {
        executedExecutableURL = executableURL
        executedArguments = arguments
        
        if shouldSucceed {
            return 0
        } else {
            return exitStatus
        }
    }
}
