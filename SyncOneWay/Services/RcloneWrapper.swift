import Foundation

class RcloneWrapper {
    private let processRunner: ProcessRunnerProtocol
    private let rcloneURL: URL?
    
    init(processRunner: ProcessRunnerProtocol = DefaultProcessRunner()) {
        self.processRunner = processRunner
        self.rcloneURL = BinaryLocator.find(name: "rclone")
    }
    
    func isRcloneAvailable() async -> Bool {
        guard let rcloneURL = rcloneURL else { return false }
        do {
            let result = try await processRunner.run(executableURL: rcloneURL, arguments: ["--version"])
            return result.terminationStatus == 0
        } catch {
            return false
        }
    }
}
