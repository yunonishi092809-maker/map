import SwiftUI
import SwiftData

@main
struct mapApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
        .modelContainer(for: [HappinessEntry.self, UserProfile.self, Key.self])
    }
}
