import SwiftUI
import MapKit

struct ContentView: View {
    @State private var showInputSheet = false
    @State private var selectedTab = 1
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var treasureBoxViewModel = TreasureBoxViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            TreasureBoxView(viewModel: treasureBoxViewModel)
                .tabItem {
                    Label("宝箱", systemImage: "shippingbox.fill")
                }
                .tag(0)

            HomeView(viewModel: homeViewModel, showInputSheet: $showInputSheet)
                .tabItem {
                    Label("ホーム", systemImage: "house.fill")
                }
                .tag(1)

            ProfileView(viewModel: profileViewModel)
                .tabItem {
                    Label("プロフィール", systemImage: "person.fill")
                }
                .tag(2)
        }
        .tint(Color.appVermillion)
        .sheet(isPresented: $showInputSheet) {
            InputView(viewModel: InputViewModel())
        }
    }
}

#Preview {
    ContentView()
}
