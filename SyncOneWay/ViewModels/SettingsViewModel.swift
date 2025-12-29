import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var sourcePath: String = ""
    @Published var destinationPath: String = ""
    
    private let repository: SettingsRepository
    
    init(repository: SettingsRepository = SettingsRepository()) {
        self.repository = repository
        self.load()
    }
    
    func load() {
        sourcePath = repository.loadSourcePath() ?? ""
        destinationPath = repository.loadDestinationPath() ?? ""
    }
    
    func save() {
        repository.saveSourcePath(sourcePath)
        repository.saveDestinationPath(destinationPath)
    }
}
