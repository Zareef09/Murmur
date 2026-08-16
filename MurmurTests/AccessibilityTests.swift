import XCTest
@testable import Murmur

final class AccessibilityTests: XCTestCase {
    func testHeroHitIsAtLeast96() {
        XCTAssertEqual(MurmurSpace.hitMin, 44)
        XCTAssertEqual(MurmurSpace.hitComfort, 56)
        XCTAssertEqual(MurmurSpace.hitHero, 96)
        XCTAssertEqual(CaptureBloom.hitSize(visual: 64, interactive: true), 96)
        XCTAssertEqual(CaptureBloom.hitSize(visual: 240, interactive: true), 240)
        XCTAssertEqual(CaptureBloom.hitSize(visual: 64, interactive: false), 64)
        XCTAssertGreaterThanOrEqual(MurmurButton.Size.sm.minHeight, MurmurSpace.hitMin)
        XCTAssertGreaterThanOrEqual(MurmurButton.Size.md.minHeight, MurmurSpace.hitMin)
        XCTAssertGreaterThanOrEqual(MurmurButton.Size.lg.minHeight, MurmurSpace.hitMin)
    }

    func testDestinationIsNeverColorOnly() {
        XCTAssertEqual(HistoryCopy.openHint(for: .reminder), "Opens in Reminders")
        XCTAssertEqual(HistoryCopy.openHint(for: .event), "Opens in Calendar")
        XCTAssertEqual(AccessibilityCopy.captureWell, "Capture a thought")
        XCTAssertEqual(AccessibilityCopy.wellHint, "Starts listening")
    }

    func testBodyTextMeetsAAOnLightAndDark() {
        // Hex pairs match Capture/DesignSystem/Colors.swift
        XCTAssertGreaterThanOrEqual(Contrast.ratio(0x211D18, 0xFFFDFA), 4.5) // primary on base, light
        XCTAssertGreaterThanOrEqual(Contrast.ratio(0x6E6455, 0xFFFDFA), 4.5) // secondary, light
        XCTAssertGreaterThanOrEqual(Contrast.ratio(0x98481D, 0xFFFDFA), 4.5) // accent text, light
        XCTAssertGreaterThanOrEqual(Contrast.ratio(0x55603C, 0xEDEFE0), 4.5) // reminder fg on chip, light
        XCTAssertGreaterThanOrEqual(Contrast.ratio(0x714A57, 0xF5E7EA), 4.5) // event fg on chip, light
        XCTAssertGreaterThanOrEqual(Contrast.ratio(0xF2EBDF, 0x201B15), 4.5) // primary, dark
        XCTAssertGreaterThanOrEqual(Contrast.ratio(0xA9A08F, 0x201B15), 4.5) // secondary, dark
        XCTAssertGreaterThanOrEqual(Contrast.ratio(0xEFBE8B, 0x201B15), 4.5) // accent text, dark
        XCTAssertGreaterThanOrEqual(Contrast.ratio(0xBFC79A, 0x201B15), 4.5) // reminder fg, dark
        XCTAssertGreaterThanOrEqual(Contrast.ratio(0xD9AEBA, 0x201B15), 4.5) // event fg, dark
        XCTAssertGreaterThanOrEqual(Contrast.ratio(0x948977, 0xFFFDFA), 3.0) // tertiary caption, light
        XCTAssertGreaterThanOrEqual(Contrast.ratio(0x7C7365, 0x201B15), 3.0) // tertiary caption, dark
    }
}

private enum Contrast {
    static func ratio(_ a: UInt32, _ b: UInt32) -> Double {
        let l1 = luminance(a)
        let l2 = luminance(b)
        let hi = max(l1, l2)
        let lo = min(l1, l2)
        return (hi + 0.05) / (lo + 0.05)
    }

    private static func luminance(_ hex: UInt32) -> Double {
        func linear(_ channel: UInt32) -> Double {
            let c = Double(channel) / 255
            return c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        let r = linear((hex >> 16) & 0xFF)
        let g = linear((hex >> 8) & 0xFF)
        let b = linear(hex & 0xFF)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
}
