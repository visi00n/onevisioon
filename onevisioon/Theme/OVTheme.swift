import SwiftUI
import Foundation

enum OVTheme {
    static let midnight = Color(hex: "0E172A")
    static let ink = Color(hex: "172033")
    static let gold = Color(hex: "B4862B")
    static let sand = Color(hex: "F5EEE2")
    static let mint = Color(hex: "D9EBDD")
    static let sky = Color(hex: "DDEAF2")
    static let lemon = Color(hex: "ECDDAB")
    static let orchid = Color(hex: "E7E1F0")
    static let coral = Color(hex: "CC7559")
    static let smoke = Color(hex: "F5F3EE")
    static let paper = Color(hex: "FFFCF7")
    static let mist = Color(hex: "EEF3F5")
    static let line = Color(hex: "E7DED1")
    static let muted = Color(hex: "6B7280")
    static let cardBackground = Color.white.opacity(0.94)
    static let elevatedCard = Color.white.opacity(0.98)
    static let tabBarBackground = paper

    static let mainBackground = LinearGradient(
        colors: [paper, sand.opacity(0.9), mist.opacity(0.82)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func display(_ size: CGFloat) -> Font {
        .custom("AvenirNext-Heavy", size: size)
    }

    static func heading(_ size: CGFloat) -> Font {
        .custom("AvenirNext-DemiBold", size: size)
    }

    static func body(_ size: CGFloat) -> Font {
        .custom("AvenirNext-Regular", size: size)
    }
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let a: UInt64
        let r: UInt64
        let g: UInt64
        let b: UInt64

        switch cleaned.count {
        case 3:
            (a, r, g, b) = (
                255,
                (value >> 8) * 17,
                (value >> 4 & 0xF) * 17,
                (value & 0xF) * 17
            )
        case 6:
            (a, r, g, b) = (
                255,
                value >> 16,
                value >> 8 & 0xFF,
                value & 0xFF
            )
        case 8:
            (a, r, g, b) = (
                value >> 24,
                value >> 16 & 0xFF,
                value >> 8 & 0xFF,
                value & 0xFF
            )
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
