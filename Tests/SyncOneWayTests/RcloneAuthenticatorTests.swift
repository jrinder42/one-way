import XCTest
@testable import SyncOneWay

final class RcloneAuthenticatorTests: XCTestCase {
    var authenticator: RcloneAuthenticator!
    var mockRunner: MockProcessRunner!
    
    override func setUp() {
        super.setUp()
        mockRunner = MockProcessRunner()
        authenticator = RcloneAuthenticator(processRunner: mockRunner)
    }
    
    func testAuthorizeReturnsTokenOnSuccess() async throws {
        let expectedToken = "{\"access_token\":\"test_token\"}"
        mockRunner.shouldSucceed = true
        mockRunner.stdout = expectedToken
        
        let token = try await authenticator.authorize(remoteType: "drive")
        
        XCTAssertEqual(token, expectedToken)
        XCTAssertNotNil(mockRunner.executedExecutableURL)
        XCTAssertEqual(mockRunner.executedArguments, ["authorize", "drive"])
    }
    
    func testAuthorizeThrowsErrorOnFailure() async {
        mockRunner.shouldSucceed = false
        mockRunner.exitStatus = 1
        mockRunner.stderr = "Auth failed"
        
        do {
            _ = try await authenticator.authorize(remoteType: "drive")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func testCreateRemoteCallsConfigCreate() async throws {
        mockRunner.shouldSucceed = true
        
        try await authenticator.createRemote(name: "SyncOneWay_GDrive", type: "drive", token: "{\"access_token\":\"test\"}")
        
        XCTAssertNotNil(mockRunner.executedExecutableURL)
        XCTAssertEqual(mockRunner.executedArguments, ["config", "create", "SyncOneWay_GDrive", "drive", "token", "{\"access_token\":\"test\"}"])
    }
}
