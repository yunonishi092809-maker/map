import SwiftUI

extension Color {
    // Vermillion Vintage Theme (朱 × 白)
    static let appVermillion = Color(red: 0.616, green: 0.184, blue: 0.141)   // #9D2F24 朱色
    static let appVermillionLight = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.45, green: 0.25, blue: 0.23, alpha: 1.0)
            : UIColor(red: 0.85, green: 0.67, blue: 0.65, alpha: 1.0)
    })
    static let appCream = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0)
            : UIColor(red: 1.0, green: 0.98, blue: 0.96, alpha: 1.0)
    })

    // 背景オーバーレイ用（ライトモードは白半透明、ダークモードは暗い色）
    static let appBackgroundOverlay = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 0.92)
            : UIColor.white.withAlphaComponent(0.5)
    })

    static let appGold = Color(red: 0.83, green: 0.69, blue: 0.22)           // #D4AF37 ゴールド
    static let appMint = Color(red: 0.66, green: 0.84, blue: 0.73)           // #A8D5BA ミント（アクセント）

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

    // Legacy
    static let customPink = appVermillion
    static let treasureGold = appGold
    static let treasureGoldLight = Color(red: 1.0, green: 0.95, blue: 0.8)
    static let appCoral = appVermillion
    static let appCoralLight = appVermillionLight
    static let appMintLight = appVermillionLight

    // Text colors
    static let appTextPrimary = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1.0)
            : UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
    })
    static let appTextSecondary = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
            : UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
    })
}
