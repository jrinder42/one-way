import XCTest
@testable import SyncOneWay

final class SettingsRepositoryTests: XCTestCase {
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
    
    func testSaveAndLoadSourcePath() {
        let expectedPath = "/Users/test/source"
        repository.saveSourcePath(expectedPath)
        XCTAssertEqual(repository.loadSourcePath(), expectedPath)
    }
    
    func testSaveAndLoadDestinationPath() {
        let expectedPath = "/Users/test/destination"
        repository.saveDestinationPath(expectedPath)
        XCTAssertEqual(repository.loadDestinationPath(), expectedPath)
    }
    
    func testSaveAndLoadDeleteFilesPreference() {
        repository.saveDeleteFilesAtDestination(true)
        XCTAssertTrue(repository.loadDeleteFilesAtDestination())
        
        repository.saveDeleteFilesAtDestination(false)
        XCTAssertFalse(repository.loadDeleteFilesAtDestination())
    }
    
    func testLoadPathsWhenEmptyReturnsNil() {
        XCTAssertNil(repository.loadSourcePath())
        XCTAssertNil(repository.loadDestinationPath())
        XCTAssertFalse(repository.loadDeleteFilesAtDestination()) // Defaults to false
    }
}

// Simple Mock for UserDefaults
class MockUserDefaults: UserDefaultsProtocol {
    private var storage: [String: Any] = [:]
    
    func set(_ value: Any?, forKey defaultName: String) {
        storage[defaultName] = value
    }
    
    func string(forKey defaultName: String) -> String? {
        return storage[defaultName] as? String
    }
    
    func bool(forKey defaultName: String) -> Bool {
        return storage[defaultName] as? Bool ?? false
    }
}
