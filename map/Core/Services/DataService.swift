import Foundation
import SwiftData

protocol DataServiceProtocol {
    func fetchEntries(context: ModelContext) -> [HappinessEntry]
    func saveEntry(_ entry: HappinessEntry, context: ModelContext)
    func deleteEntry(_ entry: HappinessEntry, context: ModelContext)
    func fetchProfile(context: ModelContext) -> UserProfile?
    func saveProfile(_ profile: UserProfile, context: ModelContext)
    func fetchKeys(context: ModelContext) -> [Key]
    func saveKey(_ key: Key, context: ModelContext)
    func fetchCollectedKeyCount(context: ModelContext) -> Int
}

final class DataService: DataServiceProtocol {
    static let shared = DataService()

    private init() {}

    func fetchEntries(context: ModelContext) -> [HappinessEntry] {
        let descriptor = FetchDescriptor<HappinessEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func saveEntry(_ entry: HappinessEntry, context: ModelContext) {
        context.insert(entry)
        try? context.save()
    }

    func deleteEntry(_ entry: HappinessEntry, context: ModelContext) {
        context.delete(entry)
        try? context.save()
    }

    func fetchProfile(context: ModelContext) -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfile>()
        return try? context.fetch(descriptor).first
    }

    func saveProfile(_ profile: UserProfile, context: ModelContext) {
        context.insert(profile)
        try? context.save()
    }

    func fetchKeys(context: ModelContext) -> [Key] {
        let descriptor = FetchDescriptor<Key>(
            sortBy: [SortDescriptor(\.collectedDate, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func saveKey(_ key: Key, context: ModelContext) {
        context.insert(key)
        try? context.save()
    }

    func fetchCollectedKeyCount(context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<Key>(
            predicate: #Predicate { $0.isCollected }
        )
        return (try? context.fetchCount(descriptor)) ?? 0
    }
}

final class MockDataService: DataServiceProtocol {
    var mockEntries: [HappinessEntry] = []
    var mockProfile: UserProfile?
    var mockKeys: [Key] = []

    func fetchEntries(context: ModelContext) -> [HappinessEntry] {
        mockEntries
    }

    func saveEntry(_ entry: HappinessEntry, context: ModelContext) {
        mockEntries.append(entry)
    }

    func deleteEntry(_ entry: HappinessEntry, context: ModelContext) {
        mockEntries.removeAll { $0.id == entry.id }
    }

    func fetchProfile(context: ModelContext) -> UserProfile? {
        mockProfile
    }

    func saveProfile(_ profile: UserProfile, context: ModelContext) {
        mockProfile = profile
    }

    func fetchKeys(context: ModelContext) -> [Key] {
        mockKeys
    }

    func saveKey(_ key: Key, context: ModelContext) {
        mockKeys.append(key)
    }

    func fetchCollectedKeyCount(context: ModelContext) -> Int {
        mockKeys.filter { $0.isCollected }.count
    }
}
