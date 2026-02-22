import Foundation
import SwiftUI
import SwiftData
import Combine

protocol ProfileViewModelProtocol: ObservableObject {
    var userName: String { get set }
    var iconImageData: Data? { get set }
    var streakDays: Int { get }
    func calculateStreak(entries: [HappinessEntry]) -> Int
    func getEntryDates(entries: [HappinessEntry]) -> Set<Date>
    func loadProfile(context: ModelContext)
    func saveProfile(context: ModelContext)
}

final class ProfileViewModel: ProfileViewModelProtocol {
    @Published var userName: String = "ゲスト"
    @Published var iconImageData: Data?
    @Published var streakDays: Int = 0

    func calculateStreak(entries: [HappinessEntry]) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var checkDate = today

        let entryDates = Set(entries.map { calendar.startOfDay(for: $0.date) })

        while entryDates.contains(checkDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                break
            }
            checkDate = previousDay
        }

        return streak
    }

    func getEntryDates(entries: [HappinessEntry]) -> Set<Date> {
        let calendar = Calendar.current
        return Set(entries.map { calendar.startOfDay(for: $0.date) })
    }

    func loadProfile(context: ModelContext) {
        let descriptor = FetchDescriptor<UserProfile>()
        guard let profile = try? context.fetch(descriptor).first else { return }
        userName = profile.userName
        iconImageData = profile.iconImageData
    }

    func saveProfile(context: ModelContext) {
        let descriptor = FetchDescriptor<UserProfile>()
        let profile: UserProfile
        if let existing = try? context.fetch(descriptor).first {
            profile = existing
        } else {
            profile = UserProfile()
            context.insert(profile)
        }
        profile.userName = userName
        profile.iconImageData = iconImageData
        try? context.save()
    }
}

final class MockProfileViewModel: ProfileViewModelProtocol {
    @Published var userName: String = "テストユーザー"
    @Published var iconImageData: Data?
    @Published var streakDays: Int = 5

    func calculateStreak(entries: [HappinessEntry]) -> Int {
        streakDays
    }

    func getEntryDates(entries: [HappinessEntry]) -> Set<Date> {
        []
    }

    func loadProfile(context: ModelContext) {}
    func saveProfile(context: ModelContext) {}
}
