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
        guard let source = repository.loadSourcePath(),
              let destination = repository.loadDestinationPath(),
              !source.isEmpty,
              !destination.isEmpty else {
            print("SyncService: Missing source or destination path. Skipping sync.")
            return
        }
        
        // Legacy support: construct a temporary WatchedFolder
        // Note: For legacy sync, we treat it as local provider
        let folder = WatchedFolder(sourcePath: source, destinationPath: destination, provider: .local)
        
        // We use the new sync(folder:) method
        try await sync(folder: folder)
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
