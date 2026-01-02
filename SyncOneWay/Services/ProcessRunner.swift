import Foundation

struct ProcessResult {
    let terminationStatus: Int32
    let standardOutput: String
    let standardError: String
}

protocol ProcessRunnerProtocol {
    func run(executableURL: URL, arguments: [String], outputHandler: ((String) -> Void)?) async throws -> ProcessResult
}

class DefaultProcessRunner: ProcessRunnerProtocol {
    func run(executableURL: URL, arguments: [String], outputHandler: ((String) -> Void)? = nil) async throws -> ProcessResult {
        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        var outputString = ""
        var errorString = ""
        
        if let outputHandler = outputHandler {
            outputPipe.fileHandleForReading.readabilityHandler = { handle in
                let data = handle.availableData
                if data.isEmpty {
                    handle.readabilityHandler = nil
                } else if let str = String(data: data, encoding: .utf8) {
                    outputString += str
                    outputHandler(str)
                }
            }
        }
        
        try process.run()
        
        if outputHandler == nil {
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            outputString = String(data: outputData, encoding: .utf8) ?? ""
        }
        
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        errorString = String(data: errorData, encoding: .utf8) ?? ""
        
        process.waitUntilExit()
        
        // Clean up readability handler if it was set
        outputPipe.fileHandleForReading.readabilityHandler = nil
        
        return ProcessResult(
            terminationStatus: process.terminationStatus,
            standardOutput: outputString,
            standardError: errorString
        )
    }
}
