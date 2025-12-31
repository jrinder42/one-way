import XCTest
@testable import SyncOneWay

final class SettingsViewModelTests: XCTestCase {
    var viewModel: SettingsViewModel!
    var mockRepository: MockSettingsRepository!
    var mockAuthenticator: MockRcloneAuthenticator!
    var mockRcloneWrapper: MockRcloneWrapper!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockSettingsRepository()
        mockAuthenticator = MockRcloneAuthenticator()
        mockRcloneWrapper = MockRcloneWrapper()
        viewModel = SettingsViewModel(
            repository: mockRepository,
            authenticator: mockAuthenticator,
            rcloneWrapper: mockRcloneWrapper
        )
    }
    
    func testInitialStateLoadsFromRepository() {
        mockRepository.sourcePath = "/repo/source"
        mockRepository.destinationPath = "/repo/destination"
        mockRepository.shouldDeleteFiles = true
        mockRepository.rcloneRemotes = [RcloneRemote(name: "TestRemote", type: "drive")]
        
        let newViewModel = SettingsViewModel(
            repository: mockRepository,
            authenticator: mockAuthenticator,
            rcloneWrapper: mockRcloneWrapper
        )
        
        XCTAssertEqual(newViewModel.sourcePath, "/repo/source")
        XCTAssertEqual(newViewModel.destinationPath, "/repo/destination")
        XCTAssertTrue(newViewModel.shouldDeleteFiles)
        XCTAssertEqual(newViewModel.rcloneRemotes.count, 1)
        XCTAssertEqual(newViewModel.rcloneRemotes[0].name, "TestRemote")
    }
    
    func testSavingUpdatesRepository() {
        viewModel.sourcePath = "/new/source"
        viewModel.destinationPath = "/new/destination"
        viewModel.shouldDeleteFiles = true
        viewModel.rcloneRemotes = [RcloneRemote(name: "NewRemote", type: "drive")]
        
        viewModel.save()
        
        XCTAssertEqual(mockRepository.savedSourcePath, "/new/source")
        XCTAssertEqual(mockRepository.savedDestinationPath, "/new/destination")
        XCTAssertTrue(mockRepository.savedShouldDeleteFiles)
        XCTAssertEqual(mockRepository.savedRcloneRemotes.count, 1)
    }
    
    func testConnectGoogleDriveSuccess() async {
        mockAuthenticator.shouldSucceed = true
        mockAuthenticator.authorizedToken = "test_token_json"
        
        await viewModel.connectGoogleDrive()
        
        XCTAssertEqual(mockAuthenticator.capturedRemoteType, "drive")
        XCTAssertEqual(mockAuthenticator.capturedCreateRemoteName, "SyncOneWay_GDrive")
        XCTAssertEqual(mockAuthenticator.capturedCreateRemoteToken, "test_token_json")
        
        XCTAssertEqual(viewModel.rcloneRemotes.count, 1)
        XCTAssertEqual(viewModel.rcloneRemotes[0].name, "SyncOneWay_GDrive")
        XCTAssertEqual(mockRepository.savedRcloneRemotes.count, 1)
    }
}

class MockSettingsRepository: SettingsRepository {
    var sourcePath: String?
    var destinationPath: String?
    var shouldDeleteFiles: Bool = false
    var rcloneRemotes: [RcloneRemote] = []
    
    var savedSourcePath: String?
    var savedDestinationPath: String?
    var savedShouldDeleteFiles: Bool = false
    var savedRcloneRemotes: [RcloneRemote] = []
    
    override func loadSourcePath() -> String? { return sourcePath }
    override func loadDestinationPath() -> String? { return destinationPath }
    override func loadDeleteFilesAtDestination() -> Bool { return shouldDeleteFiles }
    override func loadRcloneRemotes() -> [RcloneRemote] { return rcloneRemotes }
    
    override func saveSourcePath(_ path: String) { savedSourcePath = path }
    override func saveDestinationPath(_ path: String) { savedDestinationPath = path }
    override func saveDeleteFilesAtDestination(_ shouldDelete: Bool) { savedShouldDeleteFiles = shouldDelete }
    override func saveRcloneRemotes(_ remotes: [RcloneRemote]) { savedRcloneRemotes = remotes }
}
