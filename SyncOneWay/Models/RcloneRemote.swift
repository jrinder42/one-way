import Foundation

struct RcloneRemote: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var type: String
    
    init(id: UUID = UUID(), name: String, type: String) {
        self.id = id
        self.name = name
        self.type = type
    }
}
