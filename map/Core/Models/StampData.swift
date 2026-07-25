import Foundation

enum StampType: String, Codable {
    case text
    case music
    case location
}

struct StampData: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var type: StampType
    var text: String
    var relativeX: Double = 0   // -0.5...0.5 (fraction of container width from center)
    var relativeY: Double = 0   // -0.5...0.5 (fraction of container height from center)
    var scale: Double = 1
}
