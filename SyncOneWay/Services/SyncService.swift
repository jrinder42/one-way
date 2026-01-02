import Foundation

class SyncService {
    private let repository: SettingsRepository
    private let rcloneWrapper: RcloneWrapper
    private var monitors: [UUID: FileMonitor] = [:]
    
    init(repository: SettingsRepository = SettingsRepository(), 
         rcloneWrapper: RcloneWrapper = RcloneWrapper()) {
        self.repository = repository
        self.rcloneWrapper = rcloneWrapper
    }
    
    func startMonitoring() {
        stopMonitoring()
        
        let folders = repository.loadWatchedFolders()
        for folder in folders {
            let folderId = folder.id
            let monitor = FileMonitor(path: folder.sourcePath) { [weak self] in
                print("Change detected in \(folder.sourcePath)")
                // Immediate visual feedback: set status to syncing
                self?.updateStatus(id: folderId, status: .syncing, error: nil)
                
                Task {
                    // Reload folder to get latest state before sync
                    let currentFolders = self?.repository.loadWatchedFolders() ?? []
                    if let currentFolder = currentFolders.first(where: { $0.id == folderId }) {
                        try? await self?.sync(folder: currentFolder)
                    }
                }
            }
            monitor.start()
            monitors[folder.id] = monitor
        }
    }
    
    func stopMonitoring() {
        monitors.values.forEach { $0.stop() }
        monitors.removeAll()
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
                try await executeSync(folder: folder)
            } catch {
                print("Legacy sync failed: \(error.localizedDescription)")
            }
        }
        
        // 2. Sync watched folders
        let folders = repository.loadWatchedFolders()
        for folder in folders {
            try? await sync(folder: folder)
        }
    }
    
    func sync(folder: WatchedFolder) async throws {
        // Set status to syncing
        updateStatus(id: folder.id, status: .syncing, error: nil)
        
        do {
            try await executeSync(folder: folder)
            updateStatus(id: folder.id, status: .success, error: nil)
        } catch {
            updateStatus(id: folder.id, status: .failure, error: error.localizedDescription)
            throw error
        }
    }
    
    private func executeSync(folder: WatchedFolder) async throws {
        let source = folder.sourcePath
        let destination = folder.destinationPath
        
        // Ensure paths end with / for directory sync behavior
        let normalizedSource = source.hasSuffix("/") ? source : "\(source)/"
        let normalizedDestination = destination.hasSuffix("/") ? destination : "\(destination)/"
        
        let shouldDelete = repository.loadDeleteFilesAtDestination()
        
        switch folder.provider {
        case .local:
            // Use rclone for local-to-local sync (remoteName is empty)
            try await rcloneWrapper.sync(
                source: normalizedSource,
                destination: normalizedDestination,
                remoteName: "",
                deleteFiles: shouldDelete,
                bandwidthLimit: nil
            )
            
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
                bandwidthLimit: nil
            )
        }
    }
    
    private func updateStatus(id: UUID, status: SyncStatus, error: String?) {
        var folders = repository.loadWatchedFolders()
        if let index = folders.firstIndex(where: { $0.id == id }) {
            var folder = folders[index]
            folder.lastStatus = status
            folder.lastError = error
            folder.lastSyncDate = Date()
            folders[index] = folder
            repository.saveWatchedFolders(folders)
        }
    }
}
