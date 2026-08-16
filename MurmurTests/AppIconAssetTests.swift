import CoreGraphics
import ImageIO
import XCTest

final class AppIconAssetTests: XCTestCase {
    func testAppIconSetHasLightDarkAndTinted1024() throws {
        let folder = iconSetFolder()
        let light = folder.appendingPathComponent("AppIcon.png")
        let dark = folder.appendingPathComponent("AppIcon-dark.png")
        let tinted = folder.appendingPathComponent("AppIcon-tinted.png")
        XCTAssertTrue(FileManager.default.fileExists(atPath: light.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: dark.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tinted.path))

        try assertPNG(light, width: 1024, height: 1024, allowAlpha: false)
        try assertPNG(dark, width: 1024, height: 1024, allowAlpha: false)
        try assertPNG(tinted, width: 1024, height: 1024, allowAlpha: true)

        let catalog = try String(contentsOf: folder.appendingPathComponent("Contents.json"), encoding: .utf8)
        XCTAssertTrue(catalog.contains("AppIcon.png"))
        XCTAssertTrue(catalog.contains("AppIcon-dark.png"))
        XCTAssertTrue(catalog.contains("AppIcon-tinted.png"))
        XCTAssertFalse(catalog.lowercased().contains("mic"))
    }

    private func iconSetFolder() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Capture/Assets.xcassets/AppIcon.appiconset")
    }

    private func assertPNG(_ url: URL, width: Int, height: Int, allowAlpha: Bool) throws {
        let data = try Data(contentsOf: url)
        XCTAssertGreaterThan(data.count, 100)
        XCTAssertEqual(Array(data.prefix(8)), [137, 80, 78, 71, 13, 10, 26, 10])
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else {
            return XCTFail("not a PNG at \(url.lastPathComponent)")
        }
        XCTAssertEqual(image.width, width)
        XCTAssertEqual(image.height, height)
        let hasAlpha = image.alphaInfo != .none && image.alphaInfo != .noneSkipLast && image.alphaInfo != .noneSkipFirst
        if allowAlpha {
            XCTAssertTrue(hasAlpha)
        } else {
            XCTAssertFalse(hasAlpha, "\(url.lastPathComponent) must be opaque for the App Store")
        }
    }
}
