import XCTest
@testable import SyncOneWay

final class SettingsRepositoryRcloneTests: XCTestCase {
    var repository: SettingsRepository!
    var mockUserDefaults: MockUserDefaults!
    
    override func setUp() {
        super.setUp()
        mockUserDefaults = MockUserDefaults()
        repository = SettingsRepository(userDefaults: mockUserDefaults)
    }
    
    override func tearDown() {
        repository = nil
        mockUserDefaults = nil
        super.tearDown()
    }
    
    func testSaveAndLoadRcloneRemotes() {
        let remote1 = RcloneRemote(name: "Remote1", type: "drive")
        let remote2 = RcloneRemote(name: "Remote2", type: "dropbox")
        let remotes = [remote1, remote2]
        
        repository.saveRcloneRemotes(remotes)
        
        let loadedRemotes = repository.loadRcloneRemotes()
        XCTAssertEqual(loadedRemotes.count, 2)
        XCTAssertEqual(loadedRemotes[0].name, "Remote1")
        XCTAssertEqual(loadedRemotes[1].type, "dropbox")
    }
    
    func testLoadRcloneRemotesWhenEmpty() {
        let loadedRemotes = repository.loadRcloneRemotes()
        XCTAssertTrue(loadedRemotes.isEmpty)
    }
}
