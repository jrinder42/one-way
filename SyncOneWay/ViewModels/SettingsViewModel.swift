import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var sourcePath: String = ""
    @Published var destinationPath: String = ""
    @Published var shouldDeleteFiles: Bool = false
    @Published var rcloneRemotes: [RcloneRemote] = []
    @Published var watchedFolders: [WatchedFolder] = []
    @Published var isRcloneAvailable: Bool = false
    @Published var isConnecting: Bool = false
    
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
                    // We don't save to repo here to avoid side effects during load/refresh
                    // The user will save via the Save button
                }
            }
        }
    }
    
    func connectGoogleDrive() async {
        await MainActor.run { isConnecting = true }
        defer { Task { await MainActor.run { isConnecting = false } } }
        
        do {
            let token = try await authenticator.authorize(remoteType: "drive")
            let remoteName = "SyncOneWay_GDrive"
            try await authenticator.createRemote(name: remoteName, type: "drive", token: token)
            
            refreshRemotes()
        } catch {
            print("Failed to connect Google Drive: \(error.localizedDescription)")
        }
    }
    
    func deleteRemote(name: String) async throws {
        try await rcloneWrapper.deleteRemote(name: name)
        await MainActor.run {
            self.rcloneRemotes.removeAll { $0.name == name }
        }
    }
    
    func addFolder(source: String, destination: String, provider: SyncProvider, remoteId: UUID? = nil) {
        let folder = WatchedFolder(sourcePath: source, destinationPath: destination, provider: provider, remoteId: remoteId)
        watchedFolders.append(folder)
        // Note: We don't call repository.save here anymore. 
        // Changes are held in the view model until save() is called from the main Settings view.
    }
    
    func removeFolder(id: UUID) {
        watchedFolders.removeAll { $0.id == id }
    }
}
