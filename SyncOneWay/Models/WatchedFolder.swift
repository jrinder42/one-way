import Foundation

struct WatchedFolder: Identifiable, Codable {
    let id: UUID
    var sourcePath: String
    var destinationPath: String
    var provider: SyncProvider
    var remoteId: UUID?
    
    init(id: UUID = UUID(), sourcePath: String, destinationPath: String, provider: SyncProvider = .local, remoteId: UUID? = nil) {
        self.id = id
        self.sourcePath = sourcePath
        self.destinationPath = destinationPath
        self.provider = provider
        self.remoteId = remoteId
    }
    
    var isValid: Bool {
        return !sourcePath.isEmpty && !destinationPath.isEmpty
    }
}
