import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

/// Renders Murmur Home Screen icons: warm ground, the letter M. Not a microphone.
/// App Store 1024s are square and opaque (the system applies the mask). Tinted uses alpha.
///
/// The mark is drawn as a path, not typeset, so it does not depend on the bundled font. The five
/// points mirror `MurmurMark.points` in Capture/DesignSystem/AppIconView.swift — keep them in step.

enum IconKind: String {
    case light
    case dark
    case tinted
}

func makeIcon(kind: IconKind, size: Int = 1024) -> CGImage {
    let width = size
    let height = size
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let alphaInfo: CGImageAlphaInfo = kind == .tinted ? .premultipliedLast : .noneSkipLast
    let bytesPerPixel = 4
    let bytesPerRow = width * bytesPerPixel
    guard let ctx = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerRow,
        space: colorSpace,
        bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | alphaInfo.rawValue
    ) else {
        fatalError("Could not create bitmap")
    }

    let s = CGFloat(size)
    ctx.translateBy(x: 0, y: s)
    ctx.scaleBy(x: 1, y: -1)

    switch kind {
    case .light:
        fillGradient(ctx: ctx, size: s, inner: rgb(0xFFFDFA), outer: rgb(0xF0E2CD))
        strokeMark(ctx: ctx, size: s, color: rgb(0x98481D), glow: rgb(0xD2803A, alpha: 0.18))
    case .dark:
        fillGradient(ctx: ctx, size: s, inner: rgb(0x2E2820), outer: rgb(0x14110D))
        strokeMark(ctx: ctx, size: s, color: rgb(0xF6F0E6), glow: rgb(0xEFBE8B, alpha: 0.22))
    case .tinted:
        ctx.clear(CGRect(x: 0, y: 0, width: s, height: s))
        strokeMark(ctx: ctx, size: s, color: rgb(0xFFFFFF), glow: nil)
    }
    guard let image = ctx.makeImage() else {
        fatalError("Could not make image")
    }
    return image
}

func rgb(_ hex: UInt32, alpha: CGFloat = 1) -> CGColor {
    let r = CGFloat((hex >> 16) & 0xFF) / 255
    let g = CGFloat((hex >> 8) & 0xFF) / 255
    let b = CGFloat(hex & 0xFF) / 255
    return CGColor(srgbRed: r, green: g, blue: b, alpha: alpha)
}

func fillGradient(ctx: CGContext, size: CGFloat, inner: CGColor, outer: CGColor) {
    let colors = [inner, outer] as CFArray
    guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1]) else {
        return
    }
    let start = CGPoint(x: size * 0.50, y: size * 0.34)
    ctx.drawRadialGradient(
        gradient,
        startCenter: start,
        startRadius: 0,
        endCenter: CGPoint(x: size * 0.50, y: size * 0.55),
        endRadius: size * 0.85,
        options: [.drawsAfterEndLocation, .drawsBeforeStartLocation]
    )
}

/// Mirrors `MurmurMark.points`: vertical stem, V, vertical stem.
let markPoints: [CGPoint] = [
    CGPoint(x: 0.26, y: 0.72),
    CGPoint(x: 0.26, y: 0.29),
    CGPoint(x: 0.50, y: 0.60),
    CGPoint(x: 0.74, y: 0.29),
    CGPoint(x: 0.74, y: 0.72)
]

let markStrokeRatio: CGFloat = 0.105

func strokeMark(ctx: CGContext, size: CGFloat, color: CGColor, glow: CGColor?) {
    let points = markPoints.map { CGPoint(x: $0.x * size, y: $0.y * size) }
    guard let first = points.first else { return }
    if let glow {
        ctx.setShadow(offset: .zero, blur: size * 0.10, color: glow)
    }
    ctx.setStrokeColor(color)
    ctx.setLineWidth(size * markStrokeRatio)
    ctx.setLineCap(.butt)
    ctx.setLineJoin(.miter)
    ctx.setMiterLimit(10)
    ctx.beginPath()
    ctx.move(to: first)
    for point in points.dropFirst() {
        ctx.addLine(to: point)
    }
    ctx.strokePath()
    ctx.setShadow(offset: .zero, blur: 0, color: nil)
}

func writePNG(_ image: CGImage, to url: URL, opaque: Bool) {
    if FileManager.default.fileExists(atPath: url.path) {
        try? FileManager.default.removeItem(at: url)
    }
    guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        fatalError("Could not create PNG destination \(url.path)")
    }
    var props: [CFString: Any] = [:]
    if opaque {
        props[kCGImagePropertyHasAlpha] = false
    }
    CGImageDestinationAddImage(dest, image, props as CFDictionary)
    guard CGImageDestinationFinalize(dest) else {
        fatalError("Could not write \(url.path)")
    }
}

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let dir = root.appendingPathComponent("Capture/Assets.xcassets/AppIcon.appiconset")
try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

writePNG(makeIcon(kind: .light), to: dir.appendingPathComponent("AppIcon.png"), opaque: true)
writePNG(makeIcon(kind: .dark), to: dir.appendingPathComponent("AppIcon-dark.png"), opaque: true)
writePNG(makeIcon(kind: .tinted), to: dir.appendingPathComponent("AppIcon-tinted.png"), opaque: false)
print("Wrote icons in \(dir.path)")
