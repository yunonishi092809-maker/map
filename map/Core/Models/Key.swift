import Foundation
import SwiftData

@Model
final class Key {
    var id: UUID
    var latitude: Double
    var longitude: Double
    var associatedEntryId: UUID
    var isCollected: Bool
    var collectedDate: Date?
    var isUsed: Bool = false

    init(
        id: UUID = UUID(),
        latitude: Double,
        longitude: Double,
        associatedEntryId: UUID,
        isCollected: Bool = false,
        collectedDate: Date? = nil,
        isUsed: Bool = false
    ) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.associatedEntryId = associatedEntryId
        self.isCollected = isCollected
        self.collectedDate = collectedDate
        self.isUsed = isUsed
    }
}
