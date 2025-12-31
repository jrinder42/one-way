import XCTest
@testable import SyncOneWay

final class SyncServiceTests: XCTestCase {
    var syncService: SyncService!
    var mockRepository: MockSettingsRepository!
    var mockRsyncWrapper: MockRsyncWrapper!
    var mockRcloneWrapper: MockRcloneWrapper!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockSettingsRepository()
        mockRsyncWrapper = MockRsyncWrapper()
        mockRcloneWrapper = MockRcloneWrapper()
        syncService = SyncService(
            repository: mockRepository,
            rsyncWrapper: mockRsyncWrapper,
            rcloneWrapper: mockRcloneWrapper
        )
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
    
    func testSyncDelegatesToRcloneForRcloneProvider() async throws {
        let remoteId = UUID()
        let folder = WatchedFolder(
            sourcePath: "/local/path",
            destinationPath: "backup/path",
            provider: .rclone,
            remoteId: remoteId
        )
        
        // Mock the repository to return a remote for this ID
        mockRepository.rcloneRemotes = [RcloneRemote(id: remoteId, name: "MyRemote", type: "drive")]
        
        try await syncService.sync(folder: folder)
        
        XCTAssertEqual(mockRcloneWrapper.lastSource, "/local/path/")
        XCTAssertEqual(mockRcloneWrapper.lastDestination, "backup/path/")
        XCTAssertEqual(mockRcloneWrapper.lastRemoteName, "MyRemote")
    }
}

class MockRsyncWrapper: RsyncWrapper {
    var lastSource: String?
    var lastDestination: String?
    var lastDeleteFiles: Bool?
    var shouldFail = false
    
    override func sync(source: String, destination: String, deleteFiles: Bool) async throws {
        lastSource = source
        lastDestination = destination
        lastDeleteFiles = deleteFiles
        
        if shouldFail {
            throw NSError(domain: "MockRsync", code: 1, userInfo: nil)
        }
    }
}
