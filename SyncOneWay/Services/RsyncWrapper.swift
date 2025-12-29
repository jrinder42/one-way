import Foundation

protocol ProcessRunnerProtocol {
    func run(executableURL: URL, arguments: [String]) async throws -> Int32
}

class DefaultProcessRunner: ProcessRunnerProtocol {
    func run(executableURL: URL, arguments: [String]) async throws -> Int32 {
        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments
        
        try process.run()
        process.waitUntilExit()
        
        return process.terminationStatus
    }
}

class RsyncWrapper {
    private let processRunner: ProcessRunnerProtocol
    private let rsyncPath = URL(fileURLWithPath: "/usr/bin/rsync")
    
    init(processRunner: ProcessRunnerProtocol = DefaultProcessRunner()) {
        self.processRunner = processRunner
    }
    
    func sync(source: String, destination: String) async throws {
        // -a: archive mode (preserves permissions, symlinks, etc.)
        // -v: verbose
        // --delete: delete extraneous files from destination
        let arguments = ["-av", "--delete", source, destination]
        
        let status = try await processRunner.run(executableURL: rsyncPath, arguments: arguments)
        
        if status != 0 {
            throw NSError(domain: "RsyncWrapper", code: Int(status), userInfo: [NSLocalizedDescriptionKey: "rsync failed with status \(status)"])
        }
    }
}
