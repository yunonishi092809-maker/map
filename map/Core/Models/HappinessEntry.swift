import Foundation
import SwiftData

@Model
final class HappinessEntry {
    var id: UUID
    var date: Date
    var topicId: String
    var happinessText: String
    var positivityLevel: Double
    var musicTitle: String?
    var musicArtist: String?
    var locationName: String?
    var latitude: Double?
    var longitude: Double?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        topicId: String,
        happinessText: String,
        positivityLevel: Double,
        musicTitle: String? = nil,
        musicArtist: String? = nil,
        locationName: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.topicId = topicId
        self.happinessText = happinessText
        self.positivityLevel = positivityLevel
        self.musicTitle = musicTitle
        self.musicArtist = musicArtist
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
    }
}
