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
            let result = try await processRunner.run(executableURL: rcloneURL, arguments: ["--version"], outputHandler: nil)
            return result.terminationStatus == 0
        } catch {
            return false
        }
    }
    
    func listRemotes() async throws -> [String] {
        guard let url = rcloneURL else { return [] }
        let result = try await processRunner.run(executableURL: url, arguments: ["listremotes"], outputHandler: nil)
        
        if result.terminationStatus != 0 {
            throw NSError(domain: "RcloneWrapper", code: Int(result.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "rclone listremotes failed: \(result.standardError)"])
        }
        
        return result.standardOutput
            .components(separatedBy: .newlines)
            .compactMap { line -> String? in
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.isEmpty { return nil }
                return trimmed.hasSuffix(":") ? String(trimmed.dropLast()) : trimmed
            }
    }
    
    func deleteRemote(name: String) async throws {
        guard let url = rcloneURL else {
            throw NSError(domain: "RcloneWrapper", code: 2, userInfo: [NSLocalizedDescriptionKey: "rclone binary not found"])
        }
        
        let result = try await processRunner.run(executableURL: url, arguments: ["config", "delete", name], outputHandler: nil)
        
        if result.terminationStatus != 0 {
            throw NSError(domain: "RcloneWrapper", code: Int(result.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "rclone config delete failed: \(result.standardError)"])
        }
    }
    
    func sync(source: String, destination: String, remoteName: String, deleteFiles: Bool = false, bandwidthLimit: String? = nil, progressHandler: ((Double) -> Void)? = nil) async throws {
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
        
        let fullDestination = remoteName.isEmpty ? destination : "\(remoteName):\(destination)"
        arguments.append(fullDestination)
        
        let result = try await processRunner.run(executableURL: url, arguments: arguments) { output in
            if let progress = self.parseProgress(from: output) {
                progressHandler?(progress)
            }
        }
        
        if result.terminationStatus != 0 {
            throw NSError(domain: "RcloneWrapper", code: Int(result.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "rclone \(command) failed with status \(result.terminationStatus): \(result.standardError)"])
        }
    }
    
    private func parseProgress(from output: String) -> Double? {
        // Example: Transferred:   	   10.500 MiB / 10.500 MiB, 100%, 0 B/s, ETA -
        // We look for patterns like ", 100%," or ", 15%,"
        let pattern = ", (\\d+)%,"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: output, range: NSRange(output.startIndex..., in: output)) {
            if let range = Range(match.range(at: 1), in: output),
               let percentage = Double(output[range]) {
                return percentage / 100.0
            }
        }
        return nil
    }
}
