import XCTest
@testable import SyncOneWay

final class SettingsRepositoryFoldersTests: XCTestCase {
    var repository: SettingsRepository!
    var mockUserDefaults: MockUserDefaults!
    
    override func setUp() {
        super.setUp()
        mockUserDefaults = MockUserDefaults()
        repository = SettingsRepository(userDefaults: mockUserDefaults)
    }
    
    func testSaveAndLoadWatchedFolders() {
        let folder1 = WatchedFolder(sourcePath: "/src1", destinationPath: "/dest1", provider: .local)
        let folder2 = WatchedFolder(sourcePath: "/src2", destinationPath: "dest2", provider: .rclone, remoteId: UUID())
        let folders = [folder1, folder2]
        
        repository.saveWatchedFolders(folders)
        
        let loadedFolders = repository.loadWatchedFolders()
        XCTAssertEqual(loadedFolders.count, 2)
        XCTAssertEqual(loadedFolders[0].sourcePath, "/src1")
        XCTAssertEqual(loadedFolders[1].provider, .rclone)
    }
    
    func testLoadWatchedFoldersWhenEmpty() {
        let loadedFolders = repository.loadWatchedFolders()
        XCTAssertTrue(loadedFolders.isEmpty)
    }
}
