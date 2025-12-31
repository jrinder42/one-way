import Foundation

class RcloneWrapper {
    private let processRunner: ProcessRunnerProtocol
    private let rclonePath = URL(fileURLWithPath: "/usr/local/bin/rclone")
    
    init(processRunner: ProcessRunnerProtocol = DefaultProcessRunner()) {
        self.processRunner = processRunner
    }
    
    func isRcloneAvailable() async -> Bool {
        do {
            let status = try await processRunner.run(executableURL: rclonePath, arguments: ["--version"])
            return status == 0
        } catch {
            return false
        }
    }
}
