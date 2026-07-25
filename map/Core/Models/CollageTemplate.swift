import Foundation

enum CollageLayoutType: String, Codable, CaseIterable {
    case grid2x2
    case vertical
    case horizontal
    case mosaic
    case single
}

struct CollageTemplate: Identifiable, Codable {
    let id: String
    let name: String
    let layoutType: CollageLayoutType
    let photoCount: Int

    static let templates: [CollageTemplate] = [
        CollageTemplate(id: "single", name: "1枚", layoutType: .single, photoCount: 1),
        CollageTemplate(id: "vertical2", name: "2枚", layoutType: .vertical, photoCount: 2),
        CollageTemplate(id: "mosaic3", name: "3枚", layoutType: .mosaic, photoCount: 3),
        CollageTemplate(id: "grid4", name: "4枚", layoutType: .grid2x2, photoCount: 4),
    ]
}
