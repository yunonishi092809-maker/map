import SwiftUI
import SwiftData
import CoreLocation

struct TreasureBoxView<ViewModel: TreasureBoxViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @Query(sort: \HappinessEntry.date, order: .reverse) private var entries: [HappinessEntry]
    @State private var tapCount = 0
    @State private var isUnlocking = false
    @State private var keyRotation: Double = 0
    @State private var currentLocation: CLLocationCoordinate2D?
    @State private var showWeeklyReview = false
    @State private var currentIndex = 0
    @State private var isMusicPlaying = false
    @State private var currentLyrics: String?
    @State private var isLoadingLyrics = false

    private let locationService = LocationService.shared
    private let musicService = MusicService.shared

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
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .ignoresSafeArea(.all)

                Color.appBackgroundOverlay
                    .ignoresSafeArea(.all)

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

                    closedBoxView
                }

                if viewModel.isBoxOpen {
                    Color.appBackground
                        .ignoresSafeArea()

                    entriesList
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.4), value: viewModel.isBoxOpen)
            .toolbar(.hidden, for: .navigationBar)
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
                    guard !isUnlocking else { return }
                    tapCount += 1

                    withAnimation(.easeInOut(duration: 0.15)) {
                        keyRotation = -15
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            keyRotation = 15
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            keyRotation = 0
                        }
                    }

                    if tapCount >= 3 {
                        isUnlocking = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            viewModel.openBox()
                            tapCount = 0
                            isUnlocking = false
                        }
                    }
                }

            Text(isUnlocking ? "開錠中..." : "3回タップして開ける")
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
            Image("treasureBox")
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 220)
                .saturation(0.8)
                .brightness(-0.05)

            Image(systemName: isUnlocking ? "lock.open.fill" : "lock.fill")
                .font(.title)
                .foregroundStyle(Color.appVermillion)
                .rotationEffect(.degrees(keyRotation))
                .scaleEffect(isUnlocking ? 1.3 : 1.0)
                .animation(.spring(response: 0.3), value: isUnlocking)
                .offset(y: 80)
        }
        .scaleEffect(tapCount > 0 && !isUnlocking ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: tapCount)
    }

    private var currentEntry: HappinessEntry? {
        guard !nearbyEntries.isEmpty, currentIndex < nearbyEntries.count else { return nil }
        return nearbyEntries[currentIndex]
    }

    private var entriesList: some View {
        VStack(spacing: 0) {
            Button {
                stopMusic()
                currentLyrics = nil
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
            .padding(.bottom, 8)

            if nearbyEntries.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        EntryCardView(entry: nearbyEntries[currentIndex])
                            .aspectRatio(1, contentMode: .fit)
                            .padding(.horizontal)
                            .id(currentIndex)
                            .transition(.asymmetric(
                                insertion: .opacity,
                                removal: .opacity
                            ))

                        playerControls

                        lyricsSection
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .task(id: currentIndex) {
            await loadLyrics()
        }
    }

    private var lyricsSection: some View {
        Group {
            if let lyrics = currentLyrics {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "quote.opening")
                            .foregroundStyle(Color.appVermillion)
                        Text("歌詞")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appVermillion)
                    }

                    Text(lyrics)
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextPrimary)
                        .lineSpacing(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color.appCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.appVermillionLight, lineWidth: 1)
                )
                .padding(.horizontal)
            } else if isLoadingLyrics {
                ProgressView()
                    .tint(Color.appVermillion)
                    .padding()
            }
        }
    }

    private func loadLyrics() async {
        guard let entry = currentEntry, let title = entry.musicTitle else {
            currentLyrics = nil
            return
        }
        isLoadingLyrics = true
        let artist = entry.musicArtist ?? ""
        currentLyrics = await musicService.fetchLyrics(title: title, artist: artist)
        isLoadingLyrics = false
    }

    private var playerControls: some View {
        VStack(spacing: 16) {
            if let entry = currentEntry, let title = entry.musicTitle {
                HStack(spacing: 6) {
                    Image(systemName: "music.note")
                        .foregroundStyle(.white)
                    Text(title)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    if let artist = entry.musicArtist {
                        Text("- \(artist)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                .lineLimit(1)
            }

            HStack(spacing: 40) {
                Button {
                    goToPrevious()
                } label: {
                    Image(systemName: "backward.fill")
                        .font(.title2)
                        .foregroundStyle(currentIndex > 0 ? .white : .white.opacity(0.3))
                }
                .disabled(currentIndex <= 0)

                Button {
                    toggleMusic()
                } label: {
                    Image(systemName: isMusicPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(hasMusicForCurrentEntry ? .white : .white.opacity(0.3))
                }
                .disabled(!hasMusicForCurrentEntry)

                Button {
                    goToNext()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                        .foregroundStyle(currentIndex < nearbyEntries.count - 1 ? .white : .white.opacity(0.3))
                }
                .disabled(currentIndex >= nearbyEntries.count - 1)
            }

            Text("\(currentIndex + 1) / \(nearbyEntries.count)")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(Color.appVermillion)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }

    private var hasMusicForCurrentEntry: Bool {
        currentEntry?.musicTitle != nil
    }

    private func goToPrevious() {
        guard currentIndex > 0 else { return }
        stopMusic()
        withAnimation(.easeInOut(duration: 0.2)) {
            currentIndex -= 1
        }
    }

    private func goToNext() {
        guard currentIndex < nearbyEntries.count - 1 else { return }
        stopMusic()
        withAnimation(.easeInOut(duration: 0.2)) {
            currentIndex += 1
        }
    }

    private func toggleMusic() {
        if isMusicPlaying {
            musicService.pause()
            isMusicPlaying = false
        } else if let entry = currentEntry, let title = entry.musicTitle {
            let artist = entry.musicArtist ?? ""
            Task {
                await musicService.playSong(title: title, artist: artist)
                isMusicPlaying = true
            }
        }
    }

    private func stopMusic() {
        if isMusicPlaying {
            musicService.pause()
            isMusicPlaying = false
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
