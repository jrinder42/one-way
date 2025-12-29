import Foundation

class SyncService {
    private let repository: SettingsRepository
    private let rsyncWrapper: RsyncWrapper
    
    init(repository: SettingsRepository = SettingsRepository(), 
         rsyncWrapper: RsyncWrapper = RsyncWrapper()) {
        self.repository = repository
        self.rsyncWrapper = rsyncWrapper
    }
    
    func sync() async throws {
        guard let source = repository.loadSourcePath(),
              let destination = repository.loadDestinationPath(),
              !source.isEmpty,
              !destination.isEmpty else {
            print("SyncService: Missing source or destination path. Skipping sync.")
            return
        }
        
        // Ensure paths end with / for directory sync behavior if needed
        // For rsync, source/ means "contents of source"
        let normalizedSource = source.hasSuffix("/") ? source : "\(source)/"
        let normalizedDestination = destination.hasSuffix("/") ? destination : "\(destination)/"
        
        try await rsyncWrapper.sync(source: normalizedSource, destination: normalizedDestination)
    }
}
