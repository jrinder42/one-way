import Foundation

struct WatchedFolder: Identifiable, Codable {
    let id: UUID
    var sourcePath: String
    var destinationPath: String
    
    init(id: UUID = UUID(), sourcePath: String, destinationPath: String) {
        self.id = id
        self.sourcePath = sourcePath
        self.destinationPath = destinationPath
    }
    
    var isValid: Bool {
        return !sourcePath.isEmpty && !destinationPath.isEmpty
    }
}
