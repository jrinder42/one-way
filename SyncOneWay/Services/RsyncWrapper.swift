import Foundation

class RsyncWrapper {
    private let processRunner: ProcessRunnerProtocol
    private let rsyncPath = URL(fileURLWithPath: "/usr/bin/rsync")
    
    init(processRunner: ProcessRunnerProtocol = DefaultProcessRunner()) {
        self.processRunner = processRunner
    }
    
    func sync(source: String, destination: String, deleteFiles: Bool = false) async throws {
        // -a: archive mode (preserves permissions, symlinks, etc.)
        // -v: verbose
        var arguments = ["-av"]
        
        if deleteFiles {
            arguments.append("--delete")
        }
        
        arguments.append(source)
        arguments.append(destination)
        
        let result = try await processRunner.run(executableURL: rsyncPath, arguments: arguments)
        
        if result.terminationStatus != 0 {
            throw NSError(domain: "RsyncWrapper", code: Int(result.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "rsync failed with status \(result.terminationStatus): \(result.standardError)"])
        }
    }
}
