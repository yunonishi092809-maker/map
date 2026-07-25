import SwiftUI
import MapKit

struct ContentView: View {
    @State private var showInputSheet = false
    @State private var selectedTab = 0
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var treasureBoxViewModel = TreasureBoxViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 0:
                    HomeView(viewModel: homeViewModel)
                case 1:
                    TreasureBoxView(
                        viewModel: treasureBoxViewModel,
                        onFindKeys: {
                            homeViewModel.shouldFocusOnKeys = true
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                selectedTab = 0
                            }
                        },
                        onShowLocation: { coordinate in
                            homeViewModel.focusCoordinate = coordinate
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                selectedTab = 0
                            }
                        }
                    )
                default:
                    HomeView(viewModel: homeViewModel)
                }
            }
            .ignoresSafeArea(edges: .bottom)

            if !treasureBoxViewModel.isBoxOpen {
                customTabBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4), value: treasureBoxViewModel.isBoxOpen)
        .sheet(isPresented: $showInputSheet) {
            InputView(viewModel: InputViewModel())
        }
    }

    private var customTabBar: some View {
        ZStack {
            Capsule()
                .fill(Color.white)
                .overlay(
                    Capsule()
                        .stroke(Color.appVermillionLight.opacity(0.2), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 16, y: 4)
                .frame(height: 60)
                .padding(.horizontal, 32)

            HStack(spacing: 24) {
                tabButton(icon: "house.fill", label: "ホーム", tag: 0)

                centerRecordButton

                tabButton(icon: "shippingbox.fill", label: "宝箱", tag: 1)
            }
        }
        .padding(.bottom, 4)
    }

    private func tabButton(icon: String, label: String, tag: Int) -> some View {
        let isSelected = selectedTab == tag

        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                selectedTab = tag
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .symbolEffect(.bounce, value: isSelected)

                Text(label)
                    .font(.zenMaru(10, weight: .medium))
            }
            .foregroundStyle(isSelected ? Color.tabButtonBlue : Color.appTextSecondary.opacity(0.5))
            .scaleEffect(isSelected ? 1.08 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
        .frame(width: 56)
    }

    private var centerRecordButton: some View {
        Button {
            showInputSheet = true
        } label: {
            ZStack {
                Circle()
                    .fill(Color.tabButtonBlue.opacity(0.12))
                    .frame(width: 74, height: 74)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.tabButtonBlue,
                                Color.tabButtonBlue.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 58, height: 58)
                    .shadow(color: Color.tabButtonBlue.opacity(0.3), radius: 10, y: 4)

                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .offset(y: -24)
    }
}

#Preview {
    ContentView()
}
