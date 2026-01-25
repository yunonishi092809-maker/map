import SwiftUI
import SwiftData
import CoreLocation

struct TreasureBoxView<ViewModel: TreasureBoxViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @Query(sort: \HappinessEntry.date, order: .reverse) private var entries: [HappinessEntry]
    @State private var tapCount = 0
    @State private var currentLocation: CLLocationCoordinate2D?
    @State private var showWeeklyReview = false

    private let locationService = LocationService.shared

    private var isSunday: Bool {
        Calendar.current.component(.weekday, from: Date()) == 1
    }

    private var nearbyEntries: [HappinessEntry] {
        guard let location = currentLocation else {
            return Array(entries.prefix(5))
        }

        return entries
            .filter { $0.latitude != nil && $0.longitude != nil }
            .sorted { entry1, entry2 in
                let dist1 = distance(from: location, to: CLLocationCoordinate2D(latitude: entry1.latitude!, longitude: entry1.longitude!))
                let dist2 = distance(from: location, to: CLLocationCoordinate2D(latitude: entry2.latitude!, longitude: entry2.longitude!))
                return dist1 < dist2
            }
            .prefix(5)
            .map { $0 }
    }

    private var thisWeekEntries: [HappinessEntry] {
        let calendar = Calendar.current
        let now = Date()
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else {
            return []
        }
        return entries.filter { $0.date >= weekStart }
    }

    private var weeklyStamps: [Bool] {
        let calendar = Calendar.current
        let now = Date()
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else {
            return Array(repeating: false, count: 7)
        }

        let entryDates = Set(entries.map { calendar.startOfDay(for: $0.date) })

        return (0..<7).map { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else {
                return false
            }
            return entryDates.contains(calendar.startOfDay(for: date))
        }
    }

    private func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Image("background2")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                Color.white.opacity(0.5)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    WeeklyStampView(
                        stamps: weeklyStamps,
                        backgroundImageName: "stampCardBackground"
                    )
                    .padding(.horizontal)
                    .padding(.top)

                    if isSunday {
                        weeklyReviewButton
                    }

                    if viewModel.isBoxOpen {
                        entriesList
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        closedBoxView
                    }
                }
            }
            .navigationTitle("宝箱")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showWeeklyReview) {
                WeeklyReviewView(entries: thisWeekEntries)
            }
        }
        .task {
            currentLocation = await locationService.getCurrentLocation()
        }
    }

    private var weeklyReviewButton: some View {
        Button {
            showWeeklyReview = true
        } label: {
            HStack {
                Image(systemName: "calendar")
                Text("今週の振り返り")
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.appVermillion)
            .clipShape(Capsule())
        }
    }

    private var closedBoxView: some View {
        VStack(spacing: 24) {
            Spacer()

            treasureBoxIcon
                .onTapGesture {
                    tapCount += 1
                    if tapCount >= 3 {
                        viewModel.openBox()
                        tapCount = 0
                    }
                }

            Text("3回タップして開ける")
                .font(.headline)
                .foregroundStyle(Color.appVermillion)

            Text("近くの幸せ \(nearbyEntries.count)個")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)

            Spacer()
        }
    }

    private var treasureBoxIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .frame(width: 140, height: 90)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.appVermillion, lineWidth: 3)
                )
                .shadow(color: Color.appVermillion.opacity(0.2), radius: 12, y: 6)

            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .frame(width: 150, height: 25)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.appVermillion, lineWidth: 3)
                )
                .offset(y: -55)

            Image(systemName: "heart.fill")
                .font(.title2)
                .foregroundStyle(Color.appVermillion)
        }
        .scaleEffect(tapCount > 0 ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: tapCount)
    }

    private var entriesList: some View {
        VStack {
            Button {
                viewModel.closeBox()
            } label: {
                HStack {
                    Image(systemName: "chevron.down")
                    Text("閉じる")
                }
                .font(.subheadline)
                .foregroundStyle(Color.appVermillion)
            }
            .padding(.top)

            if nearbyEntries.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(nearbyEntries) { entry in
                            EntryCardView(entry: entry)
                        }
                    }
                    .padding()
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundStyle(Color.appVermillionLight)

            Text("まだ幸せが入っていません")
                .font(.headline)
                .foregroundStyle(Color.appTextSecondary)

            Text("今日の幸せを記録してみましょう")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)

            Spacer()
        }
    }
}

#Preview("Closed") {
    TreasureBoxView(viewModel: MockTreasureBoxViewModel())
}

#Preview("Open") {
    let vm = MockTreasureBoxViewModel()
    vm.isBoxOpen = true
    return TreasureBoxView(viewModel: vm)
}
