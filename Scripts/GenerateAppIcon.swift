import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

/// Renders Murmur Home Screen icons: warm well, two rings, ember core. Not a microphone.
/// App Store 1024s are square and opaque (the system applies the mask). Tinted uses alpha.

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
        fillGradient(
            ctx: ctx,
            size: s,
            inner: rgb(0xFDF3E4),
            outer: rgb(0xF0E2CD)
        )
        strokeRing(ctx: ctx, size: s, percent: 0.78, color: rgb(0x98481D, alpha: 0.22))
        strokeRing(ctx: ctx, size: s, percent: 0.54, color: rgb(0x98481D, alpha: 0.30))
        fillCore(ctx: ctx, size: s, color: rgb(0xB4602A), glow: rgb(0xD2803A, alpha: 0.42))
    case .dark:
        fillGradient(
            ctx: ctx,
            size: s,
            inner: rgb(0x34291D),
            outer: rgb(0x17130E)
        )
        strokeRing(ctx: ctx, size: s, percent: 0.78, color: rgb(0xEFBE8B, alpha: 0.30))
        strokeRing(ctx: ctx, size: s, percent: 0.54, color: rgb(0xEFBE8B, alpha: 0.42))
        fillCore(ctx: ctx, size: s, color: rgb(0xE5A063), glow: rgb(0xEFBE8B, alpha: 0.50))
    case .tinted:
        ctx.clear(CGRect(x: 0, y: 0, width: s, height: s))
        strokeRing(ctx: ctx, size: s, percent: 0.78, color: rgb(0xFFFFFF, alpha: 0.42))
        strokeRing(ctx: ctx, size: s, percent: 0.54, color: rgb(0xFFFFFF, alpha: 0.62))
        fillCore(ctx: ctx, size: s, color: rgb(0xFFFFFF), glow: rgb(0xFFFFFF, alpha: 0.28))
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

func strokeRing(ctx: CGContext, size: CGFloat, percent: CGFloat, color: CGColor) {
    let weight = max(1, size * 0.008)
    let inset = size * (1 - percent) / 2
    let rect = CGRect(x: inset, y: inset, width: size - inset * 2, height: size - inset * 2)
        .insetBy(dx: weight / 2, dy: weight / 2)
    ctx.setStrokeColor(color)
    ctx.setLineWidth(weight)
    ctx.strokeEllipse(in: rect)
}

func fillCore(ctx: CGContext, size: CGFloat, color: CGColor, glow: CGColor) {
    let inset = size * 0.38
    let rect = CGRect(x: inset, y: inset, width: size - inset * 2, height: size - inset * 2)
    ctx.setShadow(offset: .zero, blur: size * 0.22, color: glow)
    ctx.setFillColor(color)
    ctx.fillEllipse(in: rect)
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
