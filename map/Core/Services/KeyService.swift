import Foundation
import CoreLocation
import SwiftData

protocol KeyServiceProtocol {
    func generateKeysForEntries(_ entries: [HappinessEntry], existingKeys: [Key], context: ModelContext)
    func checkKeyCollection(userLocation: CLLocationCoordinate2D, keys: [Key], context: ModelContext) -> Key?
    func collect(_ key: Key, context: ModelContext)
    func collectedKeyCount(context: ModelContext) -> Int
}

final class KeyService: KeyServiceProtocol {
    static let shared = KeyService()
    private let collectionRadius: Double = 100 // meters

    private init() {}

    func generateKeysForEntries(_ entries: [HappinessEntry], existingKeys: [Key], context: ModelContext) {
        let existingEntryIds = Set(existingKeys.map { $0.associatedEntryId })

        for entry in entries {
            guard let lat = entry.latitude, let lon = entry.longitude else { continue }
            guard !existingEntryIds.contains(entry.id) else { continue }

            let key = Key(
                latitude: lat,
                longitude: lon,
                associatedEntryId: entry.id
            )
            context.insert(key)
        }
        try? context.save()
    }

    func checkKeyCollection(userLocation: CLLocationCoordinate2D, keys: [Key], context: ModelContext) -> Key? {
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)

        for key in keys where !key.isCollected {
            let keyLocation = CLLocation(latitude: key.latitude, longitude: key.longitude)
            let distance = userCLLocation.distance(from: keyLocation)

            if distance <= collectionRadius {
                key.isCollected = true
                key.collectedDate = Date()
                try? context.save()
                return key
            }
        }
        return nil
    }

    func collect(_ key: Key, context: ModelContext) {
        guard !key.isCollected else { return }
        key.isCollected = true
        key.collectedDate = Date()
        try? context.save()
    }

    func collectedKeyCount(context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<Key>(
            predicate: #Predicate { $0.isCollected }
        )
        return (try? context.fetchCount(descriptor)) ?? 0
    }
}

final class MockKeyService: KeyServiceProtocol {
    var mockCollectedKey: Key?

    func generateKeysForEntries(_ entries: [HappinessEntry], existingKeys: [Key], context: ModelContext) {}

    func checkKeyCollection(userLocation: CLLocationCoordinate2D, keys: [Key], context: ModelContext) -> Key? {
        mockCollectedKey
    }

    func collect(_ key: Key, context: ModelContext) {
        key.isCollected = true
    }

    func collectedKeyCount(context: ModelContext) -> Int { 3 }
}
