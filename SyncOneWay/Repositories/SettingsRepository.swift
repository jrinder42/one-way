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
    
    // MARK: - Watched Folders
    
    private let watchedFoldersKey = "watchedFolders"
    
    func saveWatchedFolders(_ folders: [WatchedFolder]) {
        if let encoded = try? JSONEncoder().encode(folders) {
            userDefaults.set(encoded, forKey: watchedFoldersKey)
        }
    }
    
    func loadWatchedFolders() -> [WatchedFolder] {
        if let data = userDefaults.data(forKey: watchedFoldersKey),
           let folders = try? JSONDecoder().decode([WatchedFolder].self, from: data) {
            return folders
        }
        return []
    }
}
