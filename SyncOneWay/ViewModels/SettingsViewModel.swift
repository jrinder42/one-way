import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var sourcePath: String = ""
    @Published var destinationPath: String = ""
    @Published var shouldDeleteFiles: Bool = false
    
    private let repository: SettingsRepository
    
    init(repository: SettingsRepository = SettingsRepository()) {
        self.repository = repository
        self.load()
    }
    
    func load() {
        sourcePath = repository.loadSourcePath() ?? ""
        destinationPath = repository.loadDestinationPath() ?? ""
        shouldDeleteFiles = repository.loadDeleteFilesAtDestination()
    }
    
    func save() {
        repository.saveSourcePath(sourcePath)
        repository.saveDestinationPath(destinationPath)
        repository.saveDeleteFilesAtDestination(shouldDeleteFiles)
    }
}
