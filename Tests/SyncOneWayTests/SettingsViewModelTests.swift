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
        
        let newViewModel = SettingsViewModel(repository: mockRepository)
        
        XCTAssertEqual(newViewModel.sourcePath, "/repo/source")
        XCTAssertEqual(newViewModel.destinationPath, "/repo/destination")
    }
    
    func testSavingUpdatesRepository() {
        viewModel.sourcePath = "/new/source"
        viewModel.destinationPath = "/new/destination"
        
        viewModel.save()
        
        XCTAssertEqual(mockRepository.savedSourcePath, "/new/source")
        XCTAssertEqual(mockRepository.savedDestinationPath, "/new/destination")
    }
}

class MockSettingsRepository: SettingsRepository {
    var sourcePath: String?
    var destinationPath: String?
    
    var savedSourcePath: String?
    var savedDestinationPath: String?
    
    override func loadSourcePath() -> String? { return sourcePath }
    override func loadDestinationPath() -> String? { return destinationPath }
    
    override func saveSourcePath(_ path: String) { savedSourcePath = path }
    override func saveDestinationPath(_ path: String) { savedDestinationPath = path }
}
