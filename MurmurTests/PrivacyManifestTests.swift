import XCTest
@testable import Murmur

final class PrivacyManifestTests: XCTestCase {
    func testManifestDeclaresAccountAndSettingsNotEmptyCollection() throws {
        let url = try XCTUnwrap(
            Bundle.main.url(forResource: "PrivacyInfo", withExtension: "xcprivacy")
        )
        let data = try Data(contentsOf: url)
        let plist = try XCTUnwrap(
            PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        )

        XCTAssertEqual(plist["NSPrivacyTracking"] as? Bool, false)

        let collected = try XCTUnwrap(plist["NSPrivacyCollectedDataTypes"] as? [[String: Any]])
        let types = Set(collected.compactMap { $0["NSPrivacyCollectedDataType"] as? String })
        XCTAssertEqual(
            types,
            [
                "NSPrivacyCollectedDataTypeUserID",
                "NSPrivacyCollectedDataTypeProductInteraction"
            ]
        )
        XCTAssertFalse(collected.isEmpty)

        for row in collected {
            XCTAssertEqual(row["NSPrivacyCollectedDataTypeLinked"] as? Bool, true)
            XCTAssertEqual(row["NSPrivacyCollectedDataTypeTracking"] as? Bool, false)
            let purposes = row["NSPrivacyCollectedDataTypePurposes"] as? [String]
            XCTAssertEqual(purposes, ["NSPrivacyCollectedDataTypePurposeAppFunctionality"])
        }

        let apis = try XCTUnwrap(plist["NSPrivacyAccessedAPITypes"] as? [[String: Any]])
        let userDefaults = try XCTUnwrap(
            apis.first { $0["NSPrivacyAccessedAPIType"] as? String == "NSPrivacyAccessedAPICategoryUserDefaults" }
        )
        XCTAssertEqual(userDefaults["NSPrivacyAccessedAPITypeReasons"] as? [String], ["CA92.1"])
    }
}
