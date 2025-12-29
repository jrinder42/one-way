import XCTest
@testable import SyncOneWay

final class WatchedFolderTests: XCTestCase {
    func testInitialization() {
        let id = UUID()
        let sourcePath = "/source/path"
        let destinationPath = "/destination/path"
        
        let watchedFolder = WatchedFolder(id: id, sourcePath: sourcePath, destinationPath: destinationPath)
        
        XCTAssertEqual(watchedFolder.id, id)
        XCTAssertEqual(watchedFolder.sourcePath, sourcePath)
        XCTAssertEqual(watchedFolder.destinationPath, destinationPath)
    }
    
    func testValidationSucceedsWithValidPaths() {
        let watchedFolder = WatchedFolder(sourcePath: "/valid/source", destinationPath: "/valid/destination")
        XCTAssertTrue(watchedFolder.isValid)
    }
    
    func testValidationFailsWithEmptySource() {
        let watchedFolder = WatchedFolder(sourcePath: "", destinationPath: "/valid/destination")
        XCTAssertFalse(watchedFolder.isValid)
    }
    
    func testValidationFailsWithEmptyDestination() {
        let watchedFolder = WatchedFolder(sourcePath: "/valid/source", destinationPath: "")
        XCTAssertFalse(watchedFolder.isValid)
    }
}
