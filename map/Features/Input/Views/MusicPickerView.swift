import SwiftUI
import UIKit

struct MusicPickerView<ViewModel: InputViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    var compact: Bool = false
    @State private var showSearchSheet = false

    var body: some View {
        VStack(spacing: 8) {
            Text("今日の1曲")
                .font(.headline)
                .foregroundStyle(Color.appVermillion)

            if let music = viewModel.selectedMusic {
                selectedMusicContent(music)
            } else {
                placeholderContent
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: compact ? .infinity : nil)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appVermillionLight, lineWidth: 1)
        )
        .sheet(isPresented: $showSearchSheet) {
            MusicSearchSheet(onSelect: { music in
                viewModel.selectedMusic = music
                showSearchSheet = false
            })
        }
    }

    private func selectedMusicContent(_ music: MusicItem) -> some View {
        VStack(spacing: compact ? 4 : 12) {
            CDCardView(music: music, size: compact ? 90 : 160)

            Button {
                showSearchSheet = true
            } label: {
                Text("変更")
                    .font(.caption2)
                    .foregroundStyle(Color.appVermillion)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .stroke(Color.appVermillionLight, lineWidth: 1)
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: compact ? .infinity : nil)
    }

    private var placeholderContent: some View {
        Button {
            showSearchSheet = true
        } label: {
            VStack(spacing: 6) {
                Image(systemName: "music.note.list")
                    .font(.system(size: compact ? 28 : 32))
                    .foregroundStyle(Color.appVermillionLight)

                Text("曲を選ぶ")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: compact ? .infinity : nil)
            .padding(.vertical, compact ? 0 : 24)
            .background(Color.appCream)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Search Sheet

private struct MusicSearchSheet: View {
    let onSelect: (MusicItem) -> Void

    @State private var searchText = ""
    @State private var results: [MusicItem] = []
    @State private var isSearching = false
    @State private var authStatus: MusicAuthorizationStatus = .notDetermined
    @Environment(\.dismiss) private var dismiss

    private let musicService: MusicServiceProtocol = MusicService.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if authStatus == .denied || authStatus == .restricted {
                    deniedView
                } else {
                    searchBar

                    if isSearching {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else if results.isEmpty && !searchText.isEmpty {
                        Spacer()
                        Text("曲が見つかりませんでした")
                            .foregroundStyle(Color.appTextSecondary)
                        Spacer()
                    } else if results.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "music.magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.appVermillionLight)
                            Text("曲名やアーティスト名で検索")
                                .font(.subheadline)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        Spacer()
                    } else {
                        searchResults
                    }
                }
            }
            .background(Color.appBackground)
            .navigationTitle("曲を検索")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                        .foregroundStyle(Color.appVermillion)
                }
            }
        }
        .task {
            authStatus = await musicService.requestAuthorization()
        }
    }

    private var deniedView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "music.note.slash")
                .font(.system(size: 50))
                .foregroundStyle(Color.appVermillionLight)

            Text("Apple Musicへのアクセスが\n許可されていません")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.appTextPrimary)

            Text("設定アプリから許可してください")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)

            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("設定を開く")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.appVermillion)
                    .clipShape(Capsule())
            }

            Spacer()
        }
        .padding()
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.appTextSecondary)

            TextField("曲名・アーティスト名", text: $searchText)
                .textFieldStyle(.plain)
                .submitLabel(.search)
                .onSubmit { performSearch() }

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    results = []
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        }
        .padding()
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appVermillionLight.opacity(0.5), lineWidth: 1)
        )
        .padding()
        .onChange(of: searchText) {
            performSearch()
        }
    }

    private var searchResults: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(results) { music in
                    Button {
                        onSelect(music)
                    } label: {
                        CDCardView(music: music, size: 140)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
        }
    }

    private func performSearch() {
        let query = searchText
        guard !query.isEmpty else {
            results = []
            return
        }

        isSearching = true
        Task {
            let items = await musicService.search(query: query)
            if searchText == query {
                results = items
                isSearching = false
            }
        }
    }
}

#Preview("未選択") {
    MusicPickerView(viewModel: MockInputViewModel())
        .padding()
        .background(Color.appBackground)
}

#Preview("選択済み") {
    let vm = MockInputViewModel()
    vm.selectedMusic = MusicItem(
        id: "1",
        title: "夜に駆ける",
        artistName: "YOASOBI",
        artworkURL: nil
    )
    return MusicPickerView(viewModel: vm)
        .padding()
        .background(Color.appBackground)
}

#Preview("Compact") {
    HStack(spacing: 12) {
        MusicPickerView(viewModel: MockInputViewModel(), compact: true)
            .aspectRatio(1, contentMode: .fit)

        MusicPickerView(viewModel: {
            let vm = MockInputViewModel()
            vm.selectedMusic = MusicItem(id: "1", title: "夜に駆ける", artistName: "YOASOBI", artworkURL: nil)
            return vm
        }(), compact: true)
            .aspectRatio(1, contentMode: .fit)
    }
    .padding()
    .background(Color.appBackground)
}
