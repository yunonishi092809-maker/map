import Foundation
import SwiftUI
import SwiftData
import Combine

protocol TreasureBoxViewModelProtocol: ObservableObject {
    var isBoxOpen: Bool { get set }
    func openBox()
    func closeBox()
}

final class TreasureBoxViewModel: TreasureBoxViewModelProtocol {
    @Published var isBoxOpen: Bool = false

    func openBox() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            isBoxOpen = true
        }
    }

    func closeBox() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isBoxOpen = false
        }
    }
}

final class MockTreasureBoxViewModel: TreasureBoxViewModelProtocol {
    @Published var isBoxOpen: Bool = false

    func openBox() {
        isBoxOpen = true
    }

    func closeBox() {
        isBoxOpen = false
    }
}
