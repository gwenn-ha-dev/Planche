// Sample pictures for the README captures — CHARTE.md §12.
//
//     swift outils/echantillons.swift <folder>
//
// Planche shows whatever folder it is given, and a contact sheet of someone's
// own photos is personal data. These are drawn here instead: seascapes and
// ridges in flat colours, deterministic (same files every run), in the formats
// Planche reads — JPEG, PNG and HEIC — and in three aspect ratios, with names
// that show the natural sort (shore-2 before shore-10).
import AppKit
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

guard CommandLine.arguments.count == 2 else {
    FileHandle.standardError.write("usage: echantillons.swift <folder>\n".data(using: .utf8)!)
    exit(64)
}
let folder = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

// MARK: - A small deterministic generator

struct Rand {
    var state: UInt64
    mutating func next() -> Double {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return Double(state >> 11) / Double(1 << 53)
    }
    mutating func range(_ a: Double, _ b: Double) -> Double { a + (b - a) * next() }
}

func rgb(_ hex: UInt32) -> (Double, Double, Double) {
    (Double((hex >> 16) & 0xff) / 255, Double((hex >> 8) & 0xff) / 255, Double(hex & 0xff) / 255)
}

func color(_ c: (Double, Double, Double), _ alpha: Double = 1) -> CGColor {
    CGColor(srgbRed: c.0, green: c.1, blue: c.2, alpha: alpha)
}

func mix(_ a: (Double, Double, Double), _ b: (Double, Double, Double), _ t: Double) -> (Double, Double, Double) {
    (a.0 + (b.0 - a.0) * t, a.1 + (b.1 - a.1) * t, a.2 + (b.2 - a.2) * t)
}

// MARK: - Palettes: sky top, sky at the horizon, sea near, sea far, sun

struct Palette {
    let skyTop: UInt32, skyLow: UInt32, seaFar: UInt32, seaNear: UInt32, sun: UInt32, land: UInt32
}

let palettes: [Palette] = [
    Palette(skyTop: 0x1d2b53, skyLow: 0xf7a072, seaFar: 0x6b5a7a, seaNear: 0x0e1a33, sun: 0xffe2b0, land: 0x141a2e), // dawn
    Palette(skyTop: 0x3d7cc9, skyLow: 0xcfe6fb, seaFar: 0x4f9cc9, seaNear: 0x0b3d66, sun: 0xfffbe8, land: 0x2e4a3a), // noon
    Palette(skyTop: 0x3a1c71, skyLow: 0xffaf7b, seaFar: 0xb0607a, seaNear: 0x1b0f2e, sun: 0xffd27a, land: 0x1e0f26), // sunset
    Palette(skyTop: 0x0b1026, skyLow: 0x3b4f86, seaFar: 0x2a3866, seaNear: 0x05081a, sun: 0xeef2ff, land: 0x070a18), // night
    Palette(skyTop: 0x9fb3c2, skyLow: 0xe9eef1, seaFar: 0xb9c6cf, seaNear: 0x6d8494, sun: 0xffffff, land: 0x55697a), // mist
    Palette(skyTop: 0x0f4c5c, skyLow: 0xe9c46a, seaFar: 0x2a9d8f, seaNear: 0x0b2f36, sun: 0xfff1c1, land: 0x10262b), // gold
]

// MARK: - Drawing

func linear(_ ctx: CGContext, _ from: (Double, Double, Double), _ to: (Double, Double, Double),
            _ y0: Double, _ y1: Double) {
    let g = CGGradient(colorsSpace: CGColorSpace(name: CGColorSpace.sRGB),
                       colors: [color(from), color(to)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(g, start: CGPoint(x: 0, y: y0), end: CGPoint(x: 0, y: y1),
                           options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
}

/// A ridge line: a few sines of decreasing wavelength, sampled across the width.
func ridge(_ ctx: CGContext, width w: Double, base: Double, amplitude: Double,
           fill: (Double, Double, Double), rand: inout Rand) {
    let waves = (0..<5).map { k in
        (a: amplitude / Double(k + 1) * rand.range(0.6, 1.2),
         f: Double(k + 1) * rand.range(1.5, 3.5) * .pi / w,
         p: rand.range(0, 2 * .pi))
    }
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 0, y: 0))
    var x = 0.0
    while x <= w {
        let y = base + waves.reduce(0) { $0 + $1.a * sin($1.f * x + $1.p) }
        path.addLine(to: CGPoint(x: x, y: y))
        x += 4
    }
    path.addLine(to: CGPoint(x: w, y: 0))
    path.closeSubpath()
    ctx.addPath(path)
    ctx.setFillColor(color(fill))
    ctx.fillPath()
}

enum Kind { case shore, ridge, dune }

func draw(kind: Kind, palette p: Palette, width w: Double, height h: Double, seed: UInt64) -> CGImage {
    var rand = Rand(state: seed &* 2654435761 &+ 97)
    let ctx = CGContext(data: nil, width: Int(w), height: Int(h), bitsPerComponent: 8, bytesPerRow: 0,
                        space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    let horizon = h * rand.range(0.32, 0.46)
    let skyTop = rgb(p.skyTop), skyLow = rgb(p.skyLow), sun = rgb(p.sun), land = rgb(p.land)

    // Sky
    linear(ctx, skyLow, skyTop, horizon, h)

    // Sun or moon, with a soft halo
    let sx = w * rand.range(0.25, 0.75)
    let sy = horizon + (h - horizon) * rand.range(0.12, 0.55)
    let r = min(w, h) * rand.range(0.04, 0.08)
    let halo = CGGradient(colorsSpace: CGColorSpace(name: CGColorSpace.sRGB),
                          colors: [color(sun, 0.55), color(sun, 0)] as CFArray, locations: [0, 1])!
    ctx.drawRadialGradient(halo, startCenter: CGPoint(x: sx, y: sy), startRadius: r,
                           endCenter: CGPoint(x: sx, y: sy), endRadius: r * 5, options: [])
    ctx.setFillColor(color(sun))
    ctx.fillEllipse(in: CGRect(x: sx - r, y: sy - r, width: 2 * r, height: 2 * r))

    switch kind {
    case .shore:
        // Far headlands, then the sea, the sun's path on it, and a near shore.
        ridge(ctx, width: w, base: horizon + h * 0.015, amplitude: h * 0.025,
              fill: mix(land, skyLow, 0.55), rand: &rand)
        ctx.saveGState()
        ctx.clip(to: CGRect(x: 0, y: 0, width: w, height: horizon))
        linear(ctx, rgb(p.seaNear), rgb(p.seaFar), 0, horizon)
        ctx.setFillColor(color(sun, 0.35))
        var y = horizon - 6
        while y > horizon * 0.25 {
            let spread = r * (1.2 + 3.0 * (horizon - y) / horizon) * rand.range(0.5, 1.1)
            ctx.fill(CGRect(x: sx - spread / 2 + rand.range(-r, r) * 0.3, y: y, width: spread, height: 3))
            y -= rand.range(9, 18)
        }
        ctx.restoreGState()
        ridge(ctx, width: w, base: horizon * rand.range(0.12, 0.3), amplitude: h * 0.04,
              fill: land, rand: &rand)
    case .ridge:
        // Ranges fading into the haze toward the horizon.
        let layers = 5
        for i in 0..<layers {
            let t = Double(i) / Double(layers - 1)
            ridge(ctx, width: w, base: horizon + h * 0.12 * (1 - t) - h * 0.28 * t,
                  amplitude: h * (0.05 + 0.04 * t), fill: mix(skyLow, land, 0.35 + 0.65 * t), rand: &rand)
        }
    case .dune:
        // Long, low swells of sand, lit from the sun's side.
        let sand = mix(skyLow, land, 0.25)
        for i in 0..<4 {
            let t = Double(i) / 3
            ridge(ctx, width: w, base: horizon * (1 - 0.7 * t), amplitude: h * 0.03,
                  fill: mix(sand, land, 0.2 + 0.7 * t), rand: &rand)
        }
    }
    return ctx.makeImage()!
}

func write(_ image: CGImage, to url: URL, type: UTType) {
    let dest = CGImageDestinationCreateWithURL(url as CFURL, type.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, image, [kCGImageDestinationLossyCompressionQuality: 0.85] as CFDictionary)
    guard CGImageDestinationFinalize(dest) else {
        FileHandle.standardError.write("echantillons: could not write \(url.lastPathComponent)\n".data(using: .utf8)!)
        exit(1)
    }
}

// MARK: - The set: 24 pictures

let sizes: [(Double, Double)] = [(1800, 1200), (1800, 1200), (1200, 1600), (1500, 1500)]
let plan: [(name: String, kind: Kind)] =
    (1...10).map { ("shore-\($0)", .shore) } +
    (1...8).map { ("ridge-\($0)", .ridge) } +
    (1...6).map { ("dune-\($0)", .dune) }

for (i, item) in plan.enumerated() {
    let (w, h) = sizes[(i * 7) % sizes.count]
    let palette = palettes[(i * 5 + i / 6) % palettes.count]
    let image = draw(kind: item.kind, palette: palette, width: w, height: h, seed: UInt64(i + 1))
    let type: UTType = i % 6 == 4 ? .png : (i % 6 == 2 ? .heic : .jpeg)
    let ext = type == .png ? "png" : (type == .heic ? "heic" : "jpg")
    write(image, to: folder.appendingPathComponent("\(item.name).\(ext)"), type: type)
}
print("→ \(plan.count) pictures in \(folder.lastPathComponent)/")
