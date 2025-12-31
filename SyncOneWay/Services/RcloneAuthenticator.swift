import Foundation

class RcloneAuthenticator {
    private let processRunner: ProcessRunnerProtocol
    private let rclonePath = URL(fileURLWithPath: "/usr/local/bin/rclone")
    
    init(processRunner: ProcessRunnerProtocol = DefaultProcessRunner()) {
        self.processRunner = processRunner
    }
    
    func authorize(remoteType: String) async throws -> String {
        let result = try await processRunner.run(executableURL: rclonePath, arguments: ["authorize", remoteType])
        
        if result.terminationStatus != 0 {
            throw NSError(domain: "RcloneAuthenticator", code: Int(result.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "rclone authorize failed: \(result.standardError)"])
        }
        
        return result.standardOutput.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func createRemote(name: String, type: String, token: String) async throws {
        let result = try await processRunner.run(executableURL: rclonePath, arguments: ["config", "create", name, type, "token", token])
        
        if result.terminationStatus != 0 {
            throw NSError(domain: "RcloneAuthenticator", code: Int(result.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "rclone config create failed: \(result.standardError)"])
        }
    }
}
