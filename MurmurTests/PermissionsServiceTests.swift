import AVFoundation
import EventKit
import Speech
import XCTest
@testable import Murmur

final class PermissionsServiceTests: XCTestCase {
    func testEventKitWriteOnlyIsNeeded() {
        XCTAssertEqual(PermissionsService.eventKitAccess(.fullAccess), .granted)
        XCTAssertEqual(PermissionsService.eventKitAccess(.writeOnly), .needed)
        XCTAssertEqual(PermissionsService.eventKitAccess(.denied), .needed)
        XCTAssertEqual(PermissionsService.eventKitAccess(.notDetermined), .needed)
    }

    func testMicrophoneAndSpeechMapping() {
        XCTAssertEqual(PermissionsService.microphoneAccess(.granted), .granted)
        XCTAssertEqual(PermissionsService.microphoneAccess(.denied), .needed)
        XCTAssertEqual(PermissionsService.speechAccess(.authorized), .granted)
        XCTAssertEqual(PermissionsService.speechAccess(.denied), .needed)
    }
}
