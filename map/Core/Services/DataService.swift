import Foundation
import SwiftData

protocol DataServiceProtocol {
    func fetchEntries(context: ModelContext) -> [HappinessEntry]
    func saveEntry(_ entry: HappinessEntry, context: ModelContext)
    func deleteEntry(_ entry: HappinessEntry, context: ModelContext)
    func fetchProfile(context: ModelContext) -> UserProfile?
    func saveProfile(_ profile: UserProfile, context: ModelContext)
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
}

final class MockDataService: DataServiceProtocol {
    var mockEntries: [HappinessEntry] = []
    var mockProfile: UserProfile?

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
}
