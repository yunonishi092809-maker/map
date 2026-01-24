import Foundation
import SwiftUI
import Combine

protocol HomeViewModelProtocol: ObservableObject {
    var currentTopic: Topic { get }
    var timeMode: TimeMode { get }
    var showInputButton: Bool { get }
    func refreshTimeMode()
}

final class HomeViewModel: HomeViewModelProtocol {
    @Published var currentTopic: Topic
    @Published var timeMode: TimeMode
    @Published var showInputButton: Bool

    private let timeService: TimeServiceProtocol

    init(timeService: TimeServiceProtocol = TimeService.shared) {
        self.timeService = timeService
        self.currentTopic = Topic.todaysTopic()
        self.timeMode = timeService.currentMode()
        self.showInputButton = timeService.isEveningMode()
    }

    func refreshTimeMode() {
        timeMode = timeService.currentMode()
        showInputButton = timeService.isEveningMode()
    }
}

final class MockHomeViewModel: HomeViewModelProtocol {
    @Published var currentTopic: Topic = Topic.defaultTopics[0]
    @Published var timeMode: TimeMode = .morning
    @Published var showInputButton: Bool = false

    func refreshTimeMode() {}
}
