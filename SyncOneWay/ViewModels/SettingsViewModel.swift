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
        // Load local cache first
        rcloneRemotes = repository.loadRcloneRemotes()
        watchedFolders = repository.loadWatchedFolders()
        // Then refresh from rclone
        refreshRemotes()
    }
    
    func save() {
        repository.saveSourcePath(sourcePath)
        repository.saveDestinationPath(destinationPath)
        repository.saveDeleteFilesAtDestination(shouldDeleteFiles)
        repository.saveRcloneRemotes(rcloneRemotes)
        repository.saveWatchedFolders(watchedFolders)
    }
    
    func refreshRemotes() {
        Task {
            guard await rcloneWrapper.isRcloneAvailable() else { return }
            let remoteNames = try? await rcloneWrapper.listRemotes()
            
            await MainActor.run {
                if let names = remoteNames {
                    let existingRemotes = self.repository.loadRcloneRemotes()
                    
                    self.rcloneRemotes = names.map { name in
                        if let existing = existingRemotes.first(where: { $0.name == name }) {
                            return existing
                        } else {
                            return RcloneRemote(name: name, type: "drive")
                        }
                    }
                    self.repository.saveRcloneRemotes(self.rcloneRemotes)
                }
            }
        }
    }
    
    func connectGoogleDrive() async {
        do {
            let token = try await authenticator.authorize(remoteType: "drive")
            // Use a unique name for the remote, e.g. with a timestamp or just a standard name
            let remoteName = "SyncOneWay_GDrive"
            try await authenticator.createRemote(name: remoteName, type: "drive", token: token)
            
            // Refresh to pick up the new remote
            refreshRemotes()
        } catch {
            print("Failed to connect Google Drive: \(error.localizedDescription)")
        }
    }
    
    func deleteRemote(name: String) async throws {
        try await rcloneWrapper.deleteRemote(name: name)
        refreshRemotes()
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
