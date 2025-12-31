import Foundation

struct ProcessResult {
    let terminationStatus: Int32
    let standardOutput: String
    let standardError: String
}

protocol ProcessRunnerProtocol {
    func run(executableURL: URL, arguments: [String]) async throws -> ProcessResult
}

class DefaultProcessRunner: ProcessRunnerProtocol {
    func run(executableURL: URL, arguments: [String]) async throws -> ProcessResult {
        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        
        let output = String(data: outputData, encoding: .utf8) ?? ""
        let error = String(data: errorData, encoding: .utf8) ?? ""
        
        return ProcessResult(
            terminationStatus: process.terminationStatus,
            standardOutput: output,
            standardError: error
        )
    }
}