import Foundation
import SwiftUI
import SwiftData
import Combine

protocol ProfileViewModelProtocol: ObservableObject {
    var userName: String { get set }
    var streakDays: Int { get }
    func calculateStreak(entries: [HappinessEntry]) -> Int
    func getEntryDates(entries: [HappinessEntry]) -> Set<Date>
}

final class ProfileViewModel: ProfileViewModelProtocol {
    @Published var userName: String = "ゲスト"
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
}

final class MockProfileViewModel: ProfileViewModelProtocol {
    @Published var userName: String = "テストユーザー"
    @Published var streakDays: Int = 5

    func calculateStreak(entries: [HappinessEntry]) -> Int {
        streakDays
    }

    func getEntryDates(entries: [HappinessEntry]) -> Set<Date> {
        []
    }
}
