import SwiftUI

extension Font {
    static func zenMaru(_ size: CGFloat, weight: ZenMaruWeight = .regular) -> Font {
        .custom(weight.fontName, size: size)
    }

    static func squadaOne(_ size: CGFloat) -> Font {
        .custom("SquadaOne-Regular", size: size)
    }

    enum ZenMaruWeight {
        case regular, medium, bold

        var fontName: String {
            switch self {
            case .regular: "ZenMaruGothic-Regular"
            case .medium: "ZenMaruGothic-Medium"
            case .bold: "ZenMaruGothic-Bold"
            }
        }
    }

    // Semantic font styles
    static let appLargeTitle = Font.zenMaru(34, weight: .bold)
    static let appTitle = Font.zenMaru(28, weight: .bold)
    static let appTitle2 = Font.zenMaru(22, weight: .bold)
    static let appTitle3 = Font.zenMaru(20, weight: .medium)
    static let appHeadline = Font.zenMaru(17, weight: .medium)
    static let appBody = Font.zenMaru(17)
    static let appSubheadline = Font.zenMaru(15)
    static let appFootnote = Font.zenMaru(13)
    static let appCaption = Font.zenMaru(12)
    static let appCaption2 = Font.zenMaru(11)
}
