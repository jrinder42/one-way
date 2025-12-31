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
