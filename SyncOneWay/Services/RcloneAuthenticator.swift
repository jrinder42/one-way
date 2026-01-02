import Foundation

class RcloneAuthenticator {
    private let processRunner: ProcessRunnerProtocol
    private let rcloneURL: URL?
    
    init(processRunner: ProcessRunnerProtocol = DefaultProcessRunner()) {
        self.processRunner = processRunner
        self.rcloneURL = BinaryLocator.find(name: "rclone")
    }
    
    private func getRcloneURL() throws -> URL {
        guard let url = rcloneURL else {
            throw NSError(domain: "RcloneAuthenticator", code: 2, userInfo: [NSLocalizedDescriptionKey: "rclone binary not found"])
        }
        return url
    }
    
    func authorize(remoteType: String) async throws -> String {
        let url = try getRcloneURL()
        let result = try await processRunner.run(executableURL: url, arguments: ["authorize", remoteType], outputHandler: nil)
        
        if result.terminationStatus != 0 {
            throw NSError(domain: "RcloneAuthenticator", code: Int(result.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "rclone authorize failed: \(result.standardError)"])
        }
        
        let rawOutput = result.standardOutput
        
        // Extract and compact JSON token
        guard let firstBrace = rawOutput.firstIndex(of: "{"),
              let lastBrace = rawOutput.lastIndex(of: "}") else {
            return rawOutput.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        let jsonString = String(rawOutput[firstBrace...lastBrace])
        
        if let data = jsonString.data(using: .utf8),
           let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
           let compactData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []),
           let compactString = String(data: compactData, encoding: .utf8) {
            return compactString
        }
        
        return jsonString
    }
    
    func createRemote(name: String, type: String, token: String) async throws {
        let url = try getRcloneURL()
        let result = try await processRunner.run(executableURL: url, arguments: ["config", "create", name, type, "token", token], outputHandler: nil)
        
        if result.terminationStatus != 0 {
            throw NSError(domain: "RcloneAuthenticator", code: Int(result.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "rclone config create failed: \(result.standardError)"])
        }
    }
}
