import Foundation
import UserNotifications

protocol NotificationServiceProtocol {
    func requestPermission() async -> Bool
    func scheduleDailyNotifications(morning: Date?, evening: Date?)
    func removeAllNotifications()
}

final class NotificationService: NotificationServiceProtocol {
    static let shared = NotificationService()

    private init() {}

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func scheduleDailyNotifications(morning: Date?, evening: Date?) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        if let morning {
            scheduleNotification(
                id: "morning_reminder",
                title: "おはよう！",
                body: "今日も幸せを探しに行こう",
                time: morning
            )
        }

        if let evening {
            scheduleNotification(
                id: "evening_reminder",
                title: "おつかれさま！",
                body: "今日の幸せを記録しよう",
                time: evening
            )
        }
    }

    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    private func scheduleNotification(id: String, title: String, body: String, time: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

final class MockNotificationService: NotificationServiceProtocol {
    func requestPermission() async -> Bool { true }
    func scheduleDailyNotifications(morning: Date?, evening: Date?) {}
    func removeAllNotifications() {}
}
