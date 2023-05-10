import XCTest
@testable import EnvironmentUtils

final class EnvironmentUtilsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        setUpEnv()
    }
    
    private func setUpEnv() {
        EnvironmentUtils.setEnv(envIn: EnvironmentUtils.Environment.STAGING)
    }

    func test_getEnv_isCorrect() throws {
        // NOT WORKING  TODO print("getEnv_isCorrect")
        XCTAssertEqual(EnvironmentUtils.getEnv(), "staging")
    }
    
    func test_getNudgeUrl_core_staging_isCorrect() throws {
        let serv = EnvironmentUtils.Service.CORE.rawValue
        let url = EnvironmentUtils.getNudgeURL(service: serv)
        XCTAssertEqual(url, "https://core.staging.nudge.rocks/")
    }
    
    func test_getNudgeUrl_tokendealer_staging_isCorrect() throws {
        let serv = EnvironmentUtils.Service.TOKENDEALER.rawValue
        let url = EnvironmentUtils.getNudgeURL(service: serv)
        XCTAssertEqual(url, "https://tokendealer.staging.nudge.rocks/")
    }
    
    func test_getNudgeUrl_bad_input_isCorrect() throws {
        let serv = "bad input"
        let url = EnvironmentUtils.getNudgeURL(service: serv)
        XCTAssertEqual(url, "Service name not valid.")
    }
}
