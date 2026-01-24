import SwiftUI
import SwiftData

struct HomeView<ViewModel: HomeViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @Query(sort: \HappinessEntry.date, order: .reverse) private var entries: [HappinessEntry]
    @Binding var showInputSheet: Bool

    private var averagePositivity: Double {
        guard !entries.isEmpty else { return 0 }
        return entries.reduce(0.0) { $0 + $1.positivityLevel } / Double(entries.count)
    }

    private var streakDays: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var checkDate = today

        let entryDates = Set(entries.map { calendar.startOfDay(for: $0.date) })

        while entryDates.contains(checkDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                break
            }
            checkDate = previousDay
        }

        return streak
    }

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Top bar
                HStack {
                    Spacer()
                        .frame(width: 60)

                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.appVermillion)
                        Text("\(streakDays)日")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color.appVermillion)
                    }
                    .frame(height: 28)

                    Spacer()

                    PositivityBatteryView(percentage: averagePositivity)

                    Spacer()
                        .frame(width: 60)
                }
                .padding(.top, 8)

                Spacer()

                MapCircleView(entries: entries)

                TopicCardView(topic: viewModel.currentTopic)
                    .padding(.horizontal, 32)

                if viewModel.showInputButton {
                    inputButton
                }

                Spacer()
            }
        }
        .onAppear {
            viewModel.refreshTimeMode()
        }
    }

    private var inputButton: some View {
        Button {
            showInputSheet = true
        } label: {
            Text("入力する")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 200, height: 56)
                .background(Color.appVermillion)
                .clipShape(Capsule())
                .shadow(color: Color.appVermillion.opacity(0.3), radius: 8, y: 4)
        }
    }
}

#Preview("Morning") {
    let vm = MockHomeViewModel()
    vm.timeMode = .morning
    vm.showInputButton = false
    return HomeView(viewModel: vm, showInputSheet: .constant(false))
}

#Preview("Evening") {
    let vm = MockHomeViewModel()
    vm.timeMode = .evening
    vm.showInputButton = true
    return HomeView(viewModel: vm, showInputSheet: .constant(false))
}
