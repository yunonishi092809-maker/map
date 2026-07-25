import Foundation
import SwiftData

@Model
final class HappinessEntry {
    var id: UUID
    var date: Date
    var emotionIconId: String
    var happinessText: String
    var musicTitle: String?
    var musicArtist: String?
    var locationName: String?
    var latitude: Double?
    var longitude: Double?
    @Attribute(.externalStorage) var photoData: [Data]
    var collageTemplateId: String?
    var stampsData: Data?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        emotionIconId: String,
        happinessText: String,
        musicTitle: String? = nil,
        musicArtist: String? = nil,
        locationName: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        photoData: [Data] = [],
        collageTemplateId: String? = nil,
        stampsData: Data? = nil
    ) {
        self.id = id
        self.date = date
        self.emotionIconId = emotionIconId
        self.happinessText = happinessText
        self.musicTitle = musicTitle
        self.musicArtist = musicArtist
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.photoData = photoData
        self.collageTemplateId = collageTemplateId
        self.stampsData = stampsData
    }
}

extension HappinessEntry {
    var stamps: [StampData] {
        get {
            guard let stampsData else { return [] }
            return (try? JSONDecoder().decode([StampData].self, from: stampsData)) ?? []
        }
        set {
            stampsData = try? JSONEncoder().encode(newValue)
        }
    }
}
