import Foundation

protocol UserDefaultsProtocol {
    func set(_ value: Any?, forKey defaultName: String)
    func string(forKey defaultName: String) -> String?
}

extension UserDefaults: UserDefaultsProtocol {}

class SettingsRepository {
    private let userDefaults: UserDefaultsProtocol
    private let sourcePathKey = "sourcePath"
    private let destinationPathKey = "destinationPath"
    
    init(userDefaults: UserDefaultsProtocol = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    func saveSourcePath(_ path: String) {
        userDefaults.set(path, forKey: sourcePathKey)
    }
    
    func loadSourcePath() -> String? {
        return userDefaults.string(forKey: sourcePathKey)
    }
    
    func saveDestinationPath(_ path: String) {
        userDefaults.set(path, forKey: destinationPathKey)
    }
    
    func loadDestinationPath() -> String? {
        return userDefaults.string(forKey: destinationPathKey)
    }
}
