import Foundation

class SyncService {
    private let repository: SettingsRepository
    private let rsyncWrapper: RsyncWrapper
    private let rcloneWrapper: RcloneWrapper
    
    init(repository: SettingsRepository = SettingsRepository(), 
         rsyncWrapper: RsyncWrapper = RsyncWrapper(),
         rcloneWrapper: RcloneWrapper = RcloneWrapper()) {
        self.repository = repository
        self.rsyncWrapper = rsyncWrapper
        self.rcloneWrapper = rcloneWrapper
    }
    
    func sync() async throws {
        // 1. Sync legacy folder if it exists
        if let source = repository.loadSourcePath(),
           let destination = repository.loadDestinationPath(),
           !source.isEmpty,
           !destination.isEmpty {
            
            // Legacy support: construct a temporary WatchedFolder
            let folder = WatchedFolder(sourcePath: source, destinationPath: destination, provider: .local)
            
            do {
                try await sync(folder: folder)
            } catch {
                print("Legacy sync failed: \(error.localizedDescription)")
            }
        }
        
        // 2. Sync watched folders
        var folders = repository.loadWatchedFolders()
        var updated = false
        
        for i in 0..<folders.count {
            var folder = folders[i]
            
            do {
                try await sync(folder: folder)
                folder.lastStatus = .success
                folder.lastSyncDate = Date()
                folder.lastError = nil
            } catch {
                folder.lastStatus = .failure
                folder.lastError = error.localizedDescription
                folder.lastSyncDate = Date()
                print("Failed to sync folder \(folder.id): \(error.localizedDescription)")
            }
            
            folders[i] = folder
            updated = true
        }
        
        if updated {
            repository.saveWatchedFolders(folders)
        }
    }
    
    func sync(folder: WatchedFolder) async throws {
        let source = folder.sourcePath
        let destination = folder.destinationPath
        
        // Ensure paths end with / for directory sync behavior
        let normalizedSource = source.hasSuffix("/") ? source : "\(source)/"
        let normalizedDestination = destination.hasSuffix("/") ? destination : "\(destination)/"
        
        // TODO: Move deletion preference to WatchedFolder. For now, use global setting.
        let shouldDelete = repository.loadDeleteFilesAtDestination()
        
        switch folder.provider {
        case .local:
            try await rsyncWrapper.sync(source: normalizedSource, destination: normalizedDestination, deleteFiles: shouldDelete)
            
        case .rclone:
            guard let remoteId = folder.remoteId else {
                throw NSError(domain: "SyncService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing remote ID for rclone folder"])
            }
            
            let remotes = repository.loadRcloneRemotes()
            guard let remote = remotes.first(where: { $0.id == remoteId }) else {
                throw NSError(domain: "SyncService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Remote not found"])
            }
            
            try await rcloneWrapper.sync(
                source: normalizedSource,
                destination: normalizedDestination,
                remoteName: remote.name,
                deleteFiles: shouldDelete,
                bandwidthLimit: nil // TODO: Add to WatchedFolder/Settings
            )
        }
    }
}
