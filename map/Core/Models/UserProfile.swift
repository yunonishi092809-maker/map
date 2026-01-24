import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var userName: String
    var iconName: String
    var morningNotificationTime: Date?
    var eveningNotificationTime: Date?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        userName: String = "ゲスト",
        iconName: String = "person.circle.fill",
        morningNotificationTime: Date? = nil,
        eveningNotificationTime: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userName = userName
        self.iconName = iconName
        self.morningNotificationTime = morningNotificationTime
        self.eveningNotificationTime = eveningNotificationTime
        self.createdAt = createdAt
    }
}
