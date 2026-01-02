import Foundation

enum SyncStatus: String, Codable {
    case idle
    case syncing
    case success
    case failure
}

struct WatchedFolder: Identifiable, Codable {
    let id: UUID
    var sourcePath: String
    var destinationPath: String
    var provider: SyncProvider
    var remoteId: UUID?
    var lastStatus: SyncStatus
    var lastError: String?
    var lastSyncDate: Date?
    
    init(id: UUID = UUID(), sourcePath: String, destinationPath: String, provider: SyncProvider = .local, remoteId: UUID? = nil) {
        self.id = id
        self.sourcePath = sourcePath
        self.destinationPath = destinationPath
        self.provider = provider
        self.remoteId = remoteId
        self.lastStatus = .idle
    }
    
    var isValid: Bool {
        return !sourcePath.isEmpty && !destinationPath.isEmpty
    }
}
