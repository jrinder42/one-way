import Foundation
import XCTest
@testable import SyncOneWay

class MockProcessRunner: ProcessRunnerProtocol {
    var shouldSucceed = true
    var exitStatus: Int32 = 0
    
    var executedExecutableURL: URL?
    var executedArguments: [String]?
    
    func run(executableURL: URL, arguments: [String]) async throws -> Int32 {
        executedExecutableURL = executableURL
        executedArguments = arguments
        
        if shouldSucceed {
            return 0
        } else {
            return exitStatus
        }
    }
}
