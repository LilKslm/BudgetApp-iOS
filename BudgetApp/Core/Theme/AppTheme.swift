import SwiftUI

enum AppTheme {

    enum Colors {
        static let background = Color("Background", bundle: nil, defaultLight: Color(hex: 0xFAFBFC), defaultDark: Color(hex: 0x0E1113))
        static let surface    = Color("Surface",    bundle: nil, defaultLight: Color(hex: 0xFFFFFF), defaultDark: Color(hex: 0x171A1D))
        static let surfaceMuted = Color("SurfaceMuted", bundle: nil, defaultLight: Color(hex: 0xF2F4F7), defaultDark: Color(hex: 0x1F2327))

        static let textPrimary   = Color("TextPrimary",   bundle: nil, defaultLight: Color(hex: 0x0E1113), defaultDark: Color(hex: 0xF4F6F8))
        static let textSecondary = Color("TextSecondary", bundle: nil, defaultLight: Color(hex: 0x5F6B7A), defaultDark: Color(hex: 0x9AA4B1))
        static let textTertiary  = Color("TextTertiary",  bundle: nil, defaultLight: Color(hex: 0x98A2B3), defaultDark: Color(hex: 0x6B7582))

        static let accent        = Color(hex: 0x10B981)
        static let accentSoft    = Color(hex: 0xA7F3D0)
        static let accentDeep    = Color(hex: 0x047857)

        static let success = Color(hex: 0x10B981)
        static let warning = Color(hex: 0xF59E0B)
        static let danger  = Color(hex: 0xEF4444)

        static let cardSky      = Color(hex: 0xDCEEFB)
        static let cardLavender = Color(hex: 0xE4DEFD)
        static let cardPeach    = Color(hex: 0xFDE4D5)
        static let cardMint     = Color(hex: 0xD1FAE5)

        static let divider = Color("Divider", bundle: nil, defaultLight: Color(hex: 0xE5E8EC), defaultDark: Color(hex: 0x2A2F34))
    }

    enum Gradients {
        /// Signature brand gradient — used on primary buttons, goal progress fills,
        /// active tab accents, hero numbers, progress rings. Never use raw `Colors.accent` for accent surfaces.
        static let primary = LinearGradient(
            colors: [Color(hex: 0x10B981), Color(hex: 0x06D6A0), Color(hex: 0x34E4B4)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let primarySoft = LinearGradient(
            colors: [Color(hex: 0xA7F3D0), Color(hex: 0xD1FAE5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let primaryDark = LinearGradient(
            colors: [Color(hex: 0x047857), Color(hex: 0x065F46)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let hero = LinearGradient(
            colors: [Color(hex: 0x0F9E6E), Color(hex: 0x10B981), Color(hex: 0x6EE7B7)],
            startPoint: .top,
            endPoint: .bottom
        )

        /// Subtle background wash for onboarding hero screens.
        static let backgroundWash = LinearGradient(
            colors: [Color(hex: 0xF0FDF4), Color(hex: 0xFAFBFC)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat  = 8
        static let sm: CGFloat  = 12
        static let md: CGFloat  = 16
        static let lg: CGFloat  = 24
        static let xl: CGFloat  = 32
        static let xxl: CGFloat = 48
    }

    enum Radius {
        static let sm: CGFloat  = 8
        static let md: CGFloat  = 14
        static let lg: CGFloat  = 20
        static let xl: CGFloat  = 28
        static let pill: CGFloat = 999
    }

    enum Typography {
        static let heroNumber  = Font.system(size: 44, weight: .bold, design: .rounded)
        static let largeNumber = Font.system(size: 32, weight: .bold, design: .rounded)
        static let title       = Font.system(.title2, design: .rounded).weight(.bold)
        static let headline    = Font.system(.headline, design: .default).weight(.semibold)
        static let body        = Font.system(.body, design: .default)
        static let callout     = Font.system(.callout, design: .default)
        static let caption     = Font.system(.caption, design: .default)
        static let captionBold = Font.system(.caption, design: .default).weight(.semibold)
    }

    enum Motion {
        static let quick    = Animation.spring(response: 0.28, dampingFraction: 0.85)
        static let standard = Animation.spring(response: 0.4, dampingFraction: 0.8)
        static let soft     = Animation.spring(response: 0.55, dampingFraction: 0.85)
        static let celebration = Animation.spring(response: 0.6, dampingFraction: 0.55)
    }

    enum Shadow {
        static let card = ShadowStyle(color: Color.black.opacity(0.06), radius: 14, x: 0, y: 6)
        static let raised = ShadowStyle(color: Color.black.opacity(0.10), radius: 22, x: 0, y: 12)
    }
}

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

extension View {
    func themeShadow(_ style: ShadowStyle = AppTheme.Shadow.card) -> some View {
        shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}

// MARK: - Color helpers

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }

    /// Resolves a named asset color if present; otherwise builds a dynamic light/dark color.
    /// Lets us ship the theme without requiring asset-catalog entries for every token.
    init(_ name: String, bundle: Bundle?, defaultLight: Color, defaultDark: Color) {
        #if canImport(UIKit)
        let dynamic = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(defaultDark)
                : UIColor(defaultLight)
        }
        self = Color(dynamic)
        #else
        self = defaultLight
        #endif
    }
}
