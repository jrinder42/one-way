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
    
    func sync(source: String, destination: String, remoteName: String, deleteFiles: Bool = false, bandwidthLimit: String? = nil) async throws {
        guard let url = rcloneURL else {
            throw NSError(domain: "RcloneWrapper", code: 2, userInfo: [NSLocalizedDescriptionKey: "rclone binary not found"])
        }
        
        let command = deleteFiles ? "sync" : "copy"
        var arguments = [command, "-P"]
        
        if let limit = bandwidthLimit, !limit.isEmpty {
            arguments.append("--bwlimit")
            arguments.append(limit)
        }
        
        arguments.append(source)
        arguments.append("\(remoteName):\(destination)")
        
        let result = try await processRunner.run(executableURL: url, arguments: arguments)
        
        if result.terminationStatus != 0 {
            throw NSError(domain: "RcloneWrapper", code: Int(result.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "rclone \(command) failed with status \(result.terminationStatus): \(result.standardError)"])
        }
    }
}
