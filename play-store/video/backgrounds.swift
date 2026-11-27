// Renders per-scene background PNGs (text + realistic smartphone frame + chapter bar) and rounded screen mask.
// Usage: backgrounds <height> <outDir> [iconPath]   (height 1080 => 1920x1080, 2160 => 3840x2160)
import AppKit

let H = CGFloat(Int(CommandLine.arguments[1])!)
let out = CommandLine.arguments[2]
let iconPath = CommandLine.arguments.count > 3 ? CommandLine.arguments[3] : nil
let k = H / 1080.0
let Wd = 1920 * k

func C(_ x: String, _ a: CGFloat = 1) -> NSColor {
    let v = UInt32(x.dropFirst(), radix: 16)!
    return NSColor(
        red: CGFloat(v >> 16 & 255) / 255,
        green: CGFloat(v >> 8 & 255) / 255,
        blue: CGFloat(v & 255) / 255,
        alpha: a
    )
}

struct Scene {
    let g0, g1, acc, tag, h1, h2, desc: String
    let bullets: [String]
}

let scenes: [Scene] = [
    Scene(
        g0: "#062536", g1: "#0e9eb0", acc: "#ffd54a",
        tag: "⚡  MQTT IOT CONTROL CENTER",
        h1: "OMNI REMOTE", h2: "Your IoT dashboard, anywhere.",
        desc: "Control Arduino, ESP32 & Raspberry Pi over MQTT — no account, no cloud lock-in.",
        bullets: ["⚡  Any MQTT Broker", "🎛️  Switches & Sliders", "🔒  100% Local & Private"]
    ),
    Scene(
        g0: "#101644", g1: "#295ee6", acc: "#5dffd0",
        tag: "🔗  FLEXIBLE MQTT CONNECTION",
        h1: "Connect to any", h2: "MQTT broker",
        desc: "EMQX, HiveMQ, Mosquitto or your local server — with username & password auth.",
        bullets: ["Local or cloud MQTT brokers", "Secure username & password", "Live connection indicator"]
    ),
    Scene(
        g0: "#3d0a35", g1: "#d63384", acc: "#ffe066",
        tag: "🏠  SMART GROUPS",
        h1: "Organize by room", h2: "or project",
        desc: "Group devices your way — Living Room, Bedroom, Lab or Robot — with custom icons.",
        bullets: ["Custom names & subtitles", "Live card preview", "Online status MQTT topic"]
    ),
    Scene(
        g0: "#591904", g1: "#f05a22", acc: "#fff176",
        tag: "💡  BOOLEAN SWITCHES",
        h1: "One tap.", h2: "Instant control.",
        desc: "Toggle lights, relays, pumps and outlets with real-time state confirmation.",
        bullets: ["Instant ON / OFF switches", "Hundreds of device icons", "Live interactive preview"]
    ),
    Scene(
        g0: "#052e20", g1: "#0fa36d", acc: "#b6ff4d",
        tag: "📋  AUTO MQTT TOPICS",
        h1: "Zero guesswork.", h2: "Tap to copy.",
        desc: "Command & Status topics are generated automatically — paste straight into your code.",
        bullets: ["Auto Command & Status topics", "One-tap copy to clipboard", "Ready for Arduino & ESP32"]
    ),
    Scene(
        g0: "#072c47", g1: "#0284c7", acc: "#fde047",
        tag: "🎚️  NUMERIC SLIDERS",
        h1: "Dial in speed,", h2: "light & heat",
        desc: "Fine-tune PWM brightness, thermostats, fans & servos with custom ranges.",
        bullets: ["Custom min, max & interval", "Smooth slider + / − buttons", "Real-time value sync"]
    ),
    Scene(
        g0: "#220a48", g1: "#7c3aed", acc: "#f9a8d4",
        tag: "🎨  THEMES & ACCENTS",
        h1: "Light, dark &", h2: "your color",
        desc: "Switch between Light, Dark or System theme and pick your favorite accent live.",
        bullets: ["Light, Dark & System modes", "10+ vibrant accent colors", "Material 3 Expressive UI"]
    ),
    Scene(
        g0: "#13182b", g1: "#3c4c8f", acc: "#7cf5d4",
        tag: "🔤  CUSTOM FONTS",
        h1: "Choose the font", h2: "that fits you",
        desc: "Personalize the entire dashboard typography — from clean sans to futuristic tech.",
        bullets: ["Google Sans Flex · Orbitron", "Montserrat · Nunito · Roboto", "Instant live preview"]
    ),
    Scene(
        g0: "#063a47", g1: "#0da6b8", acc: "#fff35c",
        tag: "🌍  6 LANGUAGES",
        h1: "Speak your", h2: "language",
        desc: "Switch the entire interface in one tap — no restart required.",
        bullets: ["🇬🇧 English   🇪🇸 Español", "🇮🇹 Italiano   🇩🇪 Deutsch", "🇫🇷 Français   🇵🇹 Português"]
    ),
    Scene(
        g0: "#071f33", g1: "#14809e", acc: "#ffd54a",
        tag: "🚀  OMNI REMOTE FOR ANDROID",
        h1: "Install it now", h2: "Control your hardware.",
        desc: "Turn your phone into the ultimate IoT remote for your electronics projects.",
        bullets: ["Arduino · ESP32 · ESP8266 · RPi", "No account · 100% local data", "Free on Google Play"]
    ),
]

func newCtx(_ w: Int, _ h: Int) -> (NSBitmapImageRep, CGContext) {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: w, pixelsHigh: h,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
    )!
    let g = NSGraphicsContext(bitmapImageRep: rep)!
    g.cgContext.translateBy(x: 0, y: CGFloat(h))
    g.cgContext.scaleBy(x: 1, y: -1)
    let f = NSGraphicsContext(cgContext: g.cgContext, flipped: true)
    NSGraphicsContext.current = f
    return (rep, f.cgContext)
}

func save(_ rep: NSBitmapImageRep, _ name: String) {
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "\(out)/\(name)"))
}

func fitText(
    _ s: String, maxSize: CGFloat, maxWidth: CGFloat,
    _ w: NSFont.Weight, _ col: NSColor, _ x: CGFloat, _ y: CGFloat, shadow: Bool = false
) {
    var sz = maxSize
    while sz > 32 {
        let test = NSAttributedString(string: s, attributes: [.font: NSFont.systemFont(ofSize: sz * k, weight: w)])
        if test.size().width <= maxWidth * k { break }
        sz -= 2
    }
    var a: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: sz * k, weight: w),
        .foregroundColor: col,
    ]
    if shadow {
        let sh = NSShadow()
        sh.shadowColor = NSColor.black.withAlphaComponent(0.38)
        sh.shadowBlurRadius = 18 * k
        sh.shadowOffset = NSSize(width: 0, height: -5 * k)
        a[.shadow] = sh
    }
    let dy = (maxSize - sz) * 0.35
    NSAttributedString(string: s, attributes: a).draw(at: NSPoint(x: x * k, y: (y + dy) * k))
}

// Smartphone geometry (design units @ 1080p) — exact 1080:2424 aspect ratio (418x938 @ 1080p, 836x1876 @ 4K)
let innerW: CGFloat = 418
let innerH: CGFloat = 938
let bezel: CGFloat = 16
let outerW = innerW + 2 * bezel  // 450
let outerH = innerH + 2 * bezel  // 970
let pcx: CGFloat = 450
let pcy: CGFloat = 540
let px = pcx - outerW / 2        // 225
let py = pcy - outerH / 2        // 55
let outerR: CGFloat = 56
let innerR: CGFloat = 42

let vx = Int(round((px + bezel) * k))
let vy = Int(round((py + bezel) * k))
let vw = Int(round(innerW * k))
let vh = Int(round(innerH * k))
print("VIDEO_X \(vx) VIDEO_Y \(vy) VIDEO_W \(vw) VIDEO_H \(vh)")

let tx: CGFloat = 805
let maxColW: CGFloat = 1005  // right margin = 110px

let appIcon: NSImage? = iconPath.flatMap { NSImage(contentsOfFile: $0) }

for (i, s) in scenes.enumerated() {
    let (rep, cg) = newCtx(Int(Wd), Int(H))

    // Rich radial gradient backdrop
    NSGradient(starting: C(s.g1), ending: C(s.g0))!.draw(
        fromCenter: NSPoint(x: 340 * k, y: 120 * k), radius: 0,
        toCenter: NSPoint(x: 340 * k, y: 120 * k), radius: 2150 * k,
        options: [.drawsAfterEndingLocation]
    )

    // Subtle bokeh & IoT signal rings
    for (x, y, z, a) in [
        (1780.0, 110.0, 580.0, 0.08),
        (1340.0, 990.0, 660.0, 0.06),
        (70.0, 1010.0, 420.0, 0.07),
    ] {
        C("#ffffff", CGFloat(a)).setFill()
        NSBezierPath(ovalIn: NSRect(x: (x - z / 2) * k, y: (y - z / 2) * k, width: z * k, height: z * k)).fill()
    }
    // Concentric wireless signal rings around phone
    for (rad, alpha) in [(360.0, 0.07), (470.0, 0.05), (590.0, 0.03)] {
        C("#ffffff", CGFloat(alpha)).setStroke()
        let ring = NSBezierPath(ovalIn: NSRect(x: (pcx - rad) * k, y: (pcy - rad) * k, width: (rad * 2) * k, height: (rad * 2) * k))
        ring.lineWidth = 2 * k
        ring.stroke()
    }

    // Subtle IoT circuit traces on bottom-left corner
    C("#ffffff", 0.07).setStroke()
    for offset in [0.0, 26.0, 52.0] {
        let trace = NSBezierPath()
        trace.move(to: NSPoint(x: 0, y: (860 + offset) * k))
        trace.line(to: NSPoint(x: (110 - offset * 0.6) * k, y: (860 + offset) * k))
        trace.line(to: NSPoint(x: (155 - offset * 0.6) * k, y: (905 + offset) * k))
        trace.lineWidth = 2.2 * k
        trace.stroke()
        C("#ffffff", 0.14).setFill()
        NSBezierPath(ovalIn: NSRect(x: (150 - offset * 0.6) * k, y: (900 + offset) * k, width: 10 * k, height: 10 * k)).fill()
    }

    // Right-edge hardware buttons (volume rocker + power button)
    let btnX = (px + outerW - 2) * k
    for (by, bh) in [(255.0, 108.0), (402.0, 68.0)] {
        let btnRect = NSRect(x: btnX, y: by * k, width: 8 * k, height: bh * k)
        NSGradient(starting: C("#7a8291"), ending: C("#2a2e36"))!.draw(
            in: NSBezierPath(roundedRect: btnRect, xRadius: 4 * k, yRadius: 4 * k), angle: 0
        )
    }

    // Phone outer chassis + colored accent glow
    let outerRect = NSRect(x: px * k, y: py * k, width: outerW * k, height: outerH * k)
    let outerPath = NSBezierPath(roundedRect: outerRect, xRadius: outerR * k, yRadius: outerR * k)

    cg.saveGState()
    cg.setShadow(offset: CGSize(width: 0, height: 18 * k), blur: 86 * k, color: C(s.acc, 0.45).cgColor)
    C("#181b22").setFill()
    outerPath.fill()
    cg.restoreGState()

    // Secondary deep contact shadow for crisp elevation
    cg.saveGState()
    cg.setShadow(offset: CGSize(width: 0, height: 22 * k), blur: 40 * k, color: NSColor.black.withAlphaComponent(0.45).cgColor)
    C("#181b22").setFill()
    outerPath.fill()
    cg.restoreGState()

    // Metallic titanium/graphite bezel gradient + specular rim
    NSGradient(starting: C("#555d6b"), ending: C("#161920"))!.draw(in: outerPath, angle: 135)
    C("#cfd6e2", 0.42).setStroke()
    let rimRect = NSRect(x: (px + 2.5) * k, y: (py + 2.5) * k, width: (outerW - 5) * k, height: (outerH - 5) * k)
    let rim = NSBezierPath(roundedRect: rimRect, xRadius: (outerR - 2.5) * k, yRadius: (outerR - 2.5) * k)
    rim.lineWidth = 3 * k
    rim.stroke()

    // Inner dark glass lip + pitch-black screen cutout
    let glassRect = NSRect(x: (px + 8) * k, y: (py + 8) * k, width: (outerW - 16) * k, height: (outerH - 16) * k)
    C("#0a0c10").setFill()
    NSBezierPath(roundedRect: glassRect, xRadius: (outerR - 8) * k, yRadius: (outerR - 8) * k).fill()

    let screenRect = NSRect(x: (px + bezel) * k, y: (py + bezel) * k, width: innerW * k, height: innerH * k)
    C("#000000").setFill()
    NSBezierPath(roundedRect: screenRect, xRadius: innerR * k, yRadius: innerR * k).fill()

    // Right column: Tag pill (+ app icon on Intro & Outro)
    var tagOffsetX: CGFloat = 0
    if (i == 0 || i == scenes.count - 1), let icon = appIcon {
        let iconSz: CGFloat = 54
        let iconRect = NSRect(x: tx * k, y: 152 * k, width: iconSz * k, height: iconSz * k)
        cg.saveGState()
        cg.setShadow(offset: CGSize(width: 0, height: 4 * k), blur: 12 * k, color: NSColor.black.withAlphaComponent(0.35).cgColor)
        C("#0e7d8f").setFill()
        NSBezierPath(roundedRect: iconRect, xRadius: 14 * k, yRadius: 14 * k).fill()
        cg.restoreGState()
        cg.saveGState()
        NSBezierPath(roundedRect: iconRect, xRadius: 14 * k, yRadius: 14 * k).addClip()
        icon.draw(in: iconRect, from: .zero, operation: .sourceOver, fraction: 1.0, respectFlipped: true, hints: nil)
        cg.restoreGState()
        tagOffsetX = iconSz + 16
    }

    let tagAt: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 25 * k, weight: .heavy),
        .foregroundColor: C("#ffffff", 0.96),
    ]
    let tagStr = NSAttributedString(string: s.tag, attributes: tagAt)
    let tagSz = tagStr.size()
    C("#ffffff", 0.14).setFill()
    NSBezierPath(
        roundedRect: NSRect(x: (tx + tagOffsetX) * k, y: 155 * k, width: tagSz.width + 40 * k, height: 48 * k),
        xRadius: 24 * k, yRadius: 24 * k
    ).fill()
    tagStr.draw(at: NSPoint(x: (tx + tagOffsetX) * k + 20 * k, y: 164 * k))

    // Headlines (auto-fitted so they NEVER clip!)
    let h1Size: CGFloat = i == 0 ? 120 : 88
    let h2Size: CGFloat = i == 0 ? 58 : 88
    fitText(s.h1, maxSize: h1Size, maxWidth: maxColW, .black, .white, tx, 224, shadow: true)
    fitText(s.h2, maxSize: h2Size, maxWidth: maxColW, .black, C(s.acc), tx, i == 0 ? 358 : 322, shadow: true)

    // Description
    let dy: CGFloat = i == 0 ? 452 : 446
    let para = NSMutableParagraphStyle()
    para.lineBreakMode = .byWordWrapping
    para.lineSpacing = 6 * k
    NSAttributedString(
        string: s.desc,
        attributes: [
            .font: NSFont.systemFont(ofSize: 34 * k, weight: .medium),
            .foregroundColor: C("#ffffff", 0.92),
            .paragraphStyle: para,
        ]
    ).draw(in: NSRect(x: tx * k, y: dy * k, width: maxColW * k, height: 120 * k))

    // Feature pills
    let startY: CGFloat = 594
    for (j, b) in s.bullets.enumerated() {
        let by = (startY + CGFloat(j) * 78) * k
        let label = i == 0 ? b : "✓  " + b
        let at: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 30 * k, weight: .heavy),
            .foregroundColor: C("#0c2432"),
        ]
        let a = NSAttributedString(string: label, attributes: at)
        let z = a.size()
        cg.saveGState()
        cg.setShadow(offset: CGSize(width: 0, height: 6 * k), blur: 16 * k, color: NSColor.black.withAlphaComponent(0.32).cgColor)
        C("#ffffff", 0.96).setFill()
        NSBezierPath(roundedRect: NSRect(x: tx * k, y: by, width: z.width + 48 * k, height: 58 * k), xRadius: 29 * k, yRadius: 29 * k).fill()
        cg.restoreGState()
        a.draw(at: NSPoint(x: tx * k + 24 * k, y: by + 12 * k))
    }

    // Subtle chapter progress indicator at bottom right
    let dotY: CGFloat = 955 * k
    var dotX: CGFloat = tx * k
    for idx in 0..<scenes.count {
        let active = (idx == i)
        let dw: CGFloat = (active ? 48 : 16) * k
        let dh: CGFloat = 10 * k
        (active ? C(s.acc) : C("#ffffff", idx < i ? 0.45 : 0.2)).setFill()
        NSBezierPath(roundedRect: NSRect(x: dotX, y: dotY, width: dw, height: dh), xRadius: 5 * k, yRadius: 5 * k).fill()
        dotX += dw + 12 * k
    }

    save(rep, "bg_\(i).png")
}

// Rounded-rectangle mask for the smartphone screen (white rounded rect on black), size = vw x vh
let (mrep, _) = newCtx(vw, vh)
C("#000000").setFill()
NSBezierPath(rect: NSRect(x: 0, y: 0, width: vw, height: vh)).fill()
C("#ffffff").setFill()
NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: vw, height: vh), xRadius: innerR * k, yRadius: innerR * k).fill()
save(mrep, "mask.png")
