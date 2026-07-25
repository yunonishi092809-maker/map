import SwiftUI

extension Color {
    // Blue Accent Theme (青 × 白)
    static let appVermillion = Color(red: 0.757, green: 0.859, blue: 0.910)    // #C1DBE8
    static let appVermillionLight = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.35, green: 0.45, blue: 0.55, alpha: 1.0)
            : UIColor(red: 0.85, green: 0.91, blue: 0.95, alpha: 1.0)         // #D9E8F2
    })
    static let appCream = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0)
            : UIColor(red: 1.0, green: 0.988, blue: 0.953, alpha: 1.0)        // #FFFCF3
    })

    static let appGold = Color(red: 0.83, green: 0.69, blue: 0.22)            // #D4AF37
    static let appMint = Color(red: 0.66, green: 0.84, blue: 0.73)            // #A8D5BA

    // Semantic colors
    static let appPrimary = appVermillion
    static let appSecondary = appVermillionLight
    static let appAccent = appGold
    static let appBackground = appCream
    static let appCardBackground = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1.0)
            : UIColor.white
    })

    // Page background
    static let appPageBackground = Color(red: 1.0, green: 0.988, blue: 0.953) // #FFFCF3

    // Tab bar
    static let tabButtonBlue = Color(red: 0.757, green: 0.859, blue: 0.910)   // #C1DBE8

    // Text colors — #43302E
    static let appTextPrimary = Color(red: 0.263, green: 0.188, blue: 0.180)
    static let appTextSecondary = Color(red: 0.263, green: 0.188, blue: 0.180)
}
