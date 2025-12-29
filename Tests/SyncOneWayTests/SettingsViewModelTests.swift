import XCTest
@testable import SyncOneWay

final class SettingsViewModelTests: XCTestCase {
    var viewModel: SettingsViewModel!
    var mockRepository: MockSettingsRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockSettingsRepository()
        viewModel = SettingsViewModel(repository: mockRepository)
    }
    
    func testInitialStateLoadsFromRepository() {
        mockRepository.sourcePath = "/repo/source"
        mockRepository.destinationPath = "/repo/destination"
        mockRepository.shouldDeleteFiles = true
        
        let newViewModel = SettingsViewModel(repository: mockRepository)
        
        XCTAssertEqual(newViewModel.sourcePath, "/repo/source")
        XCTAssertEqual(newViewModel.destinationPath, "/repo/destination")
        XCTAssertTrue(newViewModel.shouldDeleteFiles)
    }
    
    func testSavingUpdatesRepository() {
        viewModel.sourcePath = "/new/source"
        viewModel.destinationPath = "/new/destination"
        viewModel.shouldDeleteFiles = true
        
        viewModel.save()
        
        XCTAssertEqual(mockRepository.savedSourcePath, "/new/source")
        XCTAssertEqual(mockRepository.savedDestinationPath, "/new/destination")
        XCTAssertTrue(mockRepository.savedShouldDeleteFiles)
    }
}

class MockSettingsRepository: SettingsRepository {
    var sourcePath: String?
    var destinationPath: String?
    var shouldDeleteFiles: Bool = false
    
    var savedSourcePath: String?
    var savedDestinationPath: String?
    var savedShouldDeleteFiles: Bool = false
    
    override func loadSourcePath() -> String? { return sourcePath }
    override func loadDestinationPath() -> String? { return destinationPath }
    override func loadDeleteFilesAtDestination() -> Bool { return shouldDeleteFiles }
    
    override func saveSourcePath(_ path: String) { savedSourcePath = path }
    override func saveDestinationPath(_ path: String) { savedDestinationPath = path }
    override func saveDeleteFilesAtDestination(_ shouldDelete: Bool) { savedShouldDeleteFiles = shouldDelete }
}
