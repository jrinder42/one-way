import Foundation

protocol UserDefaultsProtocol {
    func set(_ value: Any?, forKey defaultName: String)
    func string(forKey defaultName: String) -> String?
    func bool(forKey defaultName: String) -> Bool
    func data(forKey defaultName: String) -> Data?
}

extension UserDefaults: UserDefaultsProtocol {}

class SettingsRepository {
    private let userDefaults: UserDefaultsProtocol
    private let sourcePathKey = "sourcePath"
    private let destinationPathKey = "destinationPath"
    private let deleteFilesAtDestinationKey = "deleteFilesAtDestination"
    
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

    func saveDeleteFilesAtDestination(_ shouldDelete: Bool) {
        userDefaults.set(shouldDelete, forKey: deleteFilesAtDestinationKey)
    }
    
    func loadDeleteFilesAtDestination() -> Bool {
        return userDefaults.bool(forKey: deleteFilesAtDestinationKey)
    }
    
    // MARK: - Rclone Remotes
    
    private let rcloneRemotesKey = "rcloneRemotes"
    
    func saveRcloneRemotes(_ remotes: [RcloneRemote]) {
        if let encoded = try? JSONEncoder().encode(remotes) {
            userDefaults.set(encoded, forKey: rcloneRemotesKey)
        }
    }
    
    func loadRcloneRemotes() -> [RcloneRemote] {
        if let data = userDefaults.data(forKey: rcloneRemotesKey),
           let remotes = try? JSONDecoder().decode([RcloneRemote].self, from: data) {
            return remotes
        }
        return []
    }
}
