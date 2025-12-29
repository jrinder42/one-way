import XCTest
@testable import SyncOneWay

final class SyncServiceTests: XCTestCase {
    var syncService: SyncService!
    var mockRepository: MockSettingsRepository!
    var mockRsyncWrapper: MockRsyncWrapper!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockSettingsRepository()
        mockRsyncWrapper = MockRsyncWrapper()
        syncService = SyncService(repository: mockRepository, rsyncWrapper: mockRsyncWrapper)
    }
    
    func testSyncTriggeredWithRepositoryPaths() async throws {
        mockRepository.sourcePath = "/src"
        mockRepository.destinationPath = "/dest"
        
        try await syncService.sync()
        
        XCTAssertEqual(mockRsyncWrapper.lastSource, "/src/")
        XCTAssertEqual(mockRsyncWrapper.lastDestination, "/dest/")
    }
    
    func testSyncSkipsIfPathsAreMissing() async throws {
        mockRepository.sourcePath = nil
        mockRepository.destinationPath = "/dest"
        
        try await syncService.sync()
        
        XCTAssertNil(mockRsyncWrapper.lastSource)
    }
}

class MockRsyncWrapper: RsyncWrapper {
    var lastSource: String?
    var lastDestination: String?
    var shouldFail = false
    
    override func sync(source: String, destination: String) async throws {
        lastSource = source
        lastDestination = destination
        
        if shouldFail {
            throw NSError(domain: "MockRsync", code: 1, userInfo: nil)
        }
    }
}
