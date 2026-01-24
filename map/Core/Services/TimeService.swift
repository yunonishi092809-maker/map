import Foundation
import SwiftUI

enum TimeMode {
    case morning
    case evening
}

protocol TimeServiceProtocol {
    func currentMode() -> TimeMode
    func isMorningMode() -> Bool
    func isEveningMode() -> Bool
}

final class TimeService: TimeServiceProtocol {
    static let shared = TimeService()

    private init() {}

    func currentMode() -> TimeMode {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 6 && hour < 18 {
            return .morning
        } else {
            return .evening
        }
    }

    func isMorningMode() -> Bool {
        currentMode() == .morning
    }

    func isEveningMode() -> Bool {
        currentMode() == .evening
    }
}

final class MockTimeService: TimeServiceProtocol {
    var mockMode: TimeMode = .morning

    func currentMode() -> TimeMode {
        mockMode
    }

    func isMorningMode() -> Bool {
        mockMode == .morning
    }

    func isEveningMode() -> Bool {
        mockMode == .evening
    }
}
