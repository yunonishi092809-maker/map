import SwiftUI
import SwiftData
import CoreLocation

struct TreasureBoxView<ViewModel: TreasureBoxViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    var onFindKeys: () -> Void = {}
    var onShowLocation: (CLLocationCoordinate2D) -> Void = { _ in }
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HappinessEntry.date, order: .reverse) private var entries: [HappinessEntry]
    @Query(filter: #Predicate<Key> { $0.isCollected && !$0.isUsed }) private var unusedKeys: [Key]
    @Query(filter: #Predicate<Key> { !$0.isCollected }) private var uncollectedKeys: [Key]
    @State private var showNoKeysAlert = false
    @State private var isUnlocking = false
    @State private var keyRotation: Double = 0
    @State private var albumEntries: [HappinessEntry] = []

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appPageBackground
                    .ignoresSafeArea(.all)

                cornerBlobs

                VStack(spacing: 20) {
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
            .onAppear {
                viewModel.isBoxOpen = false
            }
            .onDisappear {
                viewModel.closeBox()
            }
            .overlay {
                if showNoKeysAlert {
                    CuteAlertView(
                        title: "まだ場所が記録されていないよ",
                        message: "日記に場所を追加すると、その場所に鍵が見つかるようになるよ"
                    ) {
                        withAnimation(.easeOut(duration: 0.2)) {
                            showNoKeysAlert = false
                        }
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.92)))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showNoKeysAlert)
        }
    }

    private var cornerBlobs: some View {
        GeometryReader { geo in
            WavyBlobShape()
                .fill(Color.appVermillionLight.opacity(0.6))
                .frame(width: 340, height: 340)
                .position(x: 30, y: 20)

            WavyBlobShape(radii: [0.85, 1.05, 0.8, 1.08, 0.78, 1.02, 0.88, 1.0])
                .fill(Color.appVermillionLight.opacity(0.6))
                .frame(width: 380, height: 380)
                .position(x: geo.size.width - 30, y: geo.size.height - 20)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private var closedBoxView: some View {
        VStack(spacing: 24) {
            Spacer()

            lockStateLabel

            treasureBoxIcon
                .onTapGesture {
                    guard !isUnlocking else { return }
                    guard !unusedKeys.isEmpty else { return }

                    isUnlocking = true

                    withAnimation(.easeInOut(duration: 0.2)) {
                        keyRotation = -20
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            keyRotation = 20
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            keyRotation = 0
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        if let key = unusedKeys.first {
                            key.isUsed = true
                            try? modelContext.save()
                            viewModel.openBox()
                        }
                        isUnlocking = false
                    }
                }

            Spacer()
        }
        .offset(y: -100)
    }

    private var lockStateLabel: some View {
        let isOpenable = !unusedKeys.isEmpty
        return HStack(spacing: 12) {
            Image(systemName: isOpenable ? "lock.open.fill" : "lock.fill")
                .font(.title)
            Text(isOpenable ? "Open" : "Locked")
                .font(.squadaOne(44))
        }
        .foregroundStyle(isOpenable ? Color.appGold : Color.appTextSecondary)
        .animation(.spring(response: 0.3), value: isOpenable)
        .offset(y: 150)
        .zIndex(1)
    }

    private var findKeysButton: some View {
        Button {
            if uncollectedKeys.isEmpty {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    showNoKeysAlert = true
                }
            } else {
                onFindKeys()
            }
        } label: {
            HStack(spacing: 8) {
                Image("key")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                Text("鍵を探しに行く")
                    .font(.zenMaru(15, weight: .bold))
            }
            .foregroundStyle(Color.appTextSecondary)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.appVermillion, lineWidth: 2)
            )
            .shadow(color: Color.appVermillion.opacity(0.25), radius: 8, y: 4)
        }
    }

    private var treasureBoxIcon: some View {
        ZStack {
            Image("treasureBox")
                .resizable()
                .scaledToFit()
                .frame(width: 500, height: 500)
                .saturation(0.8)
                .brightness(-0.05)

            ZStack {
                Circle()
                    .fill(Color.appVermillionLight)
                    .frame(width: 75, height: 75)

                Image("key")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(keyRotation))
                    .scaleEffect(isUnlocking ? 1.3 : 1.0)
                    .animation(.spring(response: 0.3), value: isUnlocking)
            }
            .offset(y: 145)

            Text("開けるのには鍵が必要だよ")
                .font(.appSubheadline)
                .foregroundStyle(Color.appTextSecondary)
                .offset(y: 215)

            findKeysButton
                .offset(y: 270)
        }
        .scaleEffect(isUnlocking ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isUnlocking)
    }

    private var entriesList: some View {
        VStack(spacing: 0) {
            Button {
                viewModel.closeBox()
            } label: {
                HStack {
                    Image(systemName: "chevron.down")
                        .font(.appSubheadline)
                    Text("Close")
                        .font(.squadaOne(15))
                }
                .foregroundStyle(Color.appVermillion)
            }
            .padding(.top)
            .padding(.bottom, 8)

            if albumEntries.isEmpty {
                emptyState
            } else {
                Spacer()

               
                PhotoAlbumView(entries: albumEntries) { coordinate in
                    viewModel.closeBox()
                    onShowLocation(coordinate)
                }

                Text("タップしてめくってね")
                    .font(.appCaption)
                    .foregroundStyle(Color.appTextSecondary)
                    .padding(.top, 16)

                Spacer()
            }
        }
        .padding(.bottom, 24)
        .onAppear(perform: pickAlbumEntries)
    }

    private func pickAlbumEntries() {
        let withPhotos = entries.filter { !$0.photoData.isEmpty }
        albumEntries = Array(withPhotos.shuffled().prefix(3))
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundStyle(Color.appVermillionLight)

            Text("まだ写真の思い出がありません")
                .font(.appHeadline)
                .foregroundStyle(Color.appTextSecondary)

            Text("写真付きで記録するとアルバムに飾られるよ")
                .font(.appSubheadline)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)

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
