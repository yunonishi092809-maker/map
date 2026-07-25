import Foundation
import SwiftUI
import Combine
import CoreLocation

protocol HomeViewModelProtocol: ObservableObject {
    var timeMode: TimeMode { get }
    var shouldFocusOnKeys: Bool { get set }
    var focusCoordinate: CLLocationCoordinate2D? { get set }
    func refreshTimeMode()
}

final class HomeViewModel: HomeViewModelProtocol {
    @Published var timeMode: TimeMode
    @Published var shouldFocusOnKeys: Bool = false
    @Published var focusCoordinate: CLLocationCoordinate2D?

    private let timeService: TimeServiceProtocol

    init(timeService: TimeServiceProtocol = TimeService.shared) {
        self.timeService = timeService
        self.timeMode = timeService.currentMode()
    }

    func refreshTimeMode() {
        timeMode = timeService.currentMode()
    }
}

final class MockHomeViewModel: HomeViewModelProtocol {
    @Published var timeMode: TimeMode = .morning
    @Published var shouldFocusOnKeys: Bool = false
    @Published var focusCoordinate: CLLocationCoordinate2D?

    func refreshTimeMode() {}
}
