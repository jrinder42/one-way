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

class MockRcloneAuthenticator: RcloneAuthenticator {
    var shouldSucceed = true
    var authorizedToken = "test_token"
    
    var capturedRemoteType: String?
    var capturedCreateRemoteName: String?
    var capturedCreateRemoteType: String?
    var capturedCreateRemoteToken: String?
    
    override func authorize(remoteType: String) async throws -> String {
        capturedRemoteType = remoteType
        if shouldSucceed {
            return authorizedToken
        } else {
            throw NSError(domain: "Mock", code: 1, userInfo: nil)
        }
    }
    
    override func createRemote(name: String, type: String, token: String) async throws {
        capturedCreateRemoteName = name
        capturedCreateRemoteType = type
        capturedCreateRemoteToken = token
        if !shouldSucceed {
            throw NSError(domain: "Mock", code: 1, userInfo: nil)
        }
    }
}

class MockRcloneWrapper: RcloneWrapper {

    var available = true

    

    var lastSource: String?

    var lastDestination: String?

    var lastRemoteName: String?

    var lastDeleteFiles: Bool?

    var shouldFail = false

    

    override func isRcloneAvailable() async -> Bool {

        return available

    }

    

    override func sync(source: String, destination: String, remoteName: String, deleteFiles: Bool = false) async throws {

        lastSource = source

        lastDestination = destination

        lastRemoteName = remoteName

        lastDeleteFiles = deleteFiles

        

        if shouldFail {

            throw NSError(domain: "MockRclone", code: 1, userInfo: nil)

        }

    }

}