import SwiftUI
import SwiftData

@main
struct mapApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [HappinessEntry.self, UserProfile.self])
    }
}
