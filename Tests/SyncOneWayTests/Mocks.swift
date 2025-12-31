import Foundation
import XCTest
@testable import SyncOneWay

class MockProcessRunner: ProcessRunnerProtocol {
    var shouldSucceed = true
    var exitStatus: Int32 = 0
    var stdout = ""
    var stderr = ""
    
    var executedExecutableURL: URL?
    var executedArguments: [String]?
    
    func run(executableURL: URL, arguments: [String]) async throws -> ProcessResult {
        executedExecutableURL = executableURL
        executedArguments = arguments
        
        let status = shouldSucceed ? 0 : exitStatus
        
        return ProcessResult(
            terminationStatus: status,
            standardOutput: stdout,
            standardError: stderr
        )
    }
}