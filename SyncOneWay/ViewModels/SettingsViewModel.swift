import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var sourcePath: String = ""
    @Published var destinationPath: String = ""
    @Published var shouldDeleteFiles: Bool = false
    @Published var rcloneRemotes: [RcloneRemote] = []
    @Published var watchedFolders: [WatchedFolder] = []
    @Published var isRcloneAvailable: Bool = false
    
    private let repository: SettingsRepository
    private let authenticator: RcloneAuthenticator
    private let rcloneWrapper: RcloneWrapper
    
    init(
        repository: SettingsRepository = SettingsRepository(),
        authenticator: RcloneAuthenticator = RcloneAuthenticator(),
        rcloneWrapper: RcloneWrapper = RcloneWrapper()
    ) {
        self.repository = repository
        self.authenticator = authenticator
        self.rcloneWrapper = rcloneWrapper
        self.load()
        
        Task {
            let available = await rcloneWrapper.isRcloneAvailable()
            await MainActor.run {
                self.isRcloneAvailable = available
            }
        }
    }
    
    func load() {
        sourcePath = repository.loadSourcePath() ?? ""
        destinationPath = repository.loadDestinationPath() ?? ""
        shouldDeleteFiles = repository.loadDeleteFilesAtDestination()
        rcloneRemotes = repository.loadRcloneRemotes()
        watchedFolders = repository.loadWatchedFolders()
    }
    
    func save() {
        repository.saveSourcePath(sourcePath)
        repository.saveDestinationPath(destinationPath)
        repository.saveDeleteFilesAtDestination(shouldDeleteFiles)
        repository.saveRcloneRemotes(rcloneRemotes)
        repository.saveWatchedFolders(watchedFolders)
    }
    
    func connectGoogleDrive() async {
        do {
            let token = try await authenticator.authorize(remoteType: "drive")
            // Use a unique name for the remote, e.g. with a timestamp or just a standard name
            let remoteName = "SyncOneWay_GDrive"
            try await authenticator.createRemote(name: remoteName, type: "drive", token: token)
            
            let newRemote = RcloneRemote(name: remoteName, type: "drive")
            
            await MainActor.run {
                self.rcloneRemotes.append(newRemote)
                self.repository.saveRcloneRemotes(self.rcloneRemotes)
            }
        } catch {
            print("Failed to connect Google Drive: \(error.localizedDescription)")
        }
    }
    
    func addFolder(source: String, destination: String, provider: SyncProvider, remoteId: UUID? = nil) {
        let folder = WatchedFolder(sourcePath: source, destinationPath: destination, provider: provider, remoteId: remoteId)
        watchedFolders.append(folder)
        repository.saveWatchedFolders(watchedFolders)
    }
    
    func removeFolder(id: UUID) {
        watchedFolders.removeAll { $0.id == id }
        repository.saveWatchedFolders(watchedFolders)
    }
}
