import SwiftUI
import SwiftData

struct InputView<ViewModel: InputViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showPraiseCard = false
    @State private var savedHappinessText = ""
    @State private var showQuickPicks = false
    @FocusState private var isTextEditorFocused: Bool

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

                ScrollView {
                    VStack(spacing: 20) {
                        topicSection

                        happinessInputSection

                        PositivitySliderView(value: $viewModel.positivityLevel)
                            .padding(.horizontal)

                        HStack(spacing: 12) {
                            MusicPickerView(viewModel: viewModel, compact: true)
                                .aspectRatio(1, contentMode: .fit)

                            LocationPickerView(
                                locationName: $viewModel.locationName,
                                isLoadingLocation: .constant(viewModel.isLoadingLocation),
                                onRequestCurrentLocation: {
                                    Task {
                                        await viewModel.fetchLocation()
                                    }
                                },
                                compact: true
                            )
                            .aspectRatio(1, contentMode: .fit)
                        }
                        .padding(.horizontal)

                        saveButton
                            .padding(.top, 8)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("今日の幸せ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        dismiss()
                    }
                    .foregroundStyle(Color.appVermillion)
                }
            }
        }
        .task {
            await viewModel.fetchLocation()
        }
        .overlay {
            if showPraiseCard {
                PraiseCardView(happinessText: savedHappinessText) {
                    dismiss()
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.spring(response: 0.4), value: showPraiseCard)
    }

    private var topicSection: some View {
        VStack(spacing: 8) {
            Text("今日のお題")
                .font(.subheadline)
                .foregroundStyle(Color.appVermillion)

            Text(viewModel.currentTopic.inputQuestion)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appVermillionLight, lineWidth: 1)
        )
        .padding(.horizontal)
    }

    private let maxCharacterCount = 100

    private var happinessInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("今日の幸せ")
                    .font(.headline)
                    .foregroundStyle(Color.appVermillion)

                Spacer()

                Text("\(viewModel.happinessText.count)/\(maxCharacterCount)")
                    .font(.caption)
                    .foregroundStyle(
                        viewModel.happinessText.count > maxCharacterCount
                            ? Color.red
                            : Color.appTextSecondary
                    )
            }

            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.happinessText)
                    .frame(minHeight: 80)
                    .scrollContentBackground(.hidden)
                    .padding()
                    .background(Color.appCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.appVermillionLight.opacity(0.5), lineWidth: 1)
                    )
                    .focused($isTextEditorFocused)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("完了") {
                                isTextEditorFocused = false
                            }
                            .foregroundStyle(Color.appVermillion)
                        }
                    }

                if viewModel.happinessText.isEmpty {
                    Text("今日あった良かったことを書いてね")
                        .foregroundStyle(Color.appTextSecondary.opacity(0.6))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                        .allowsHitTesting(false)
                }
            }
            .onChange(of: viewModel.happinessText) {
                    if viewModel.happinessText.count > maxCharacterCount {
                        viewModel.happinessText = String(viewModel.happinessText.prefix(maxCharacterCount))
                    }
                }

            Button {
                showQuickPicks = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                    Text("思いつかない…？ここから選ぼう")
                }
                .font(.subheadline)
                .foregroundStyle(Color.appVermillion)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.appCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.appVermillionLight.opacity(0.5), lineWidth: 1)
                )
            }
        }
        .padding()
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appVermillionLight, lineWidth: 1)
        )
        .padding(.horizontal)
        .sheet(isPresented: $showQuickPicks) {
            QuickPickSheet { text in
                viewModel.happinessText = text
                showQuickPicks = false
            }
            .presentationDetents([.medium])
        }
    }

    private var saveButton: some View {
        Button {
            Task {
                savedHappinessText = viewModel.happinessText
                await viewModel.saveEntry(context: modelContext)
                showPraiseCard = true
            }
        } label: {
            if viewModel.isSaving {
                ProgressView()
                    .tint(.white)
            } else {
                Text("宝箱に入れる")
                    .font(.title3)
                    .fontWeight(.bold)
            }
        }
        .foregroundStyle(.white)
        .frame(width: 200, height: 56)
        .background(Color.appVermillion)
        .clipShape(Capsule())
        .shadow(color: Color.appVermillion.opacity(0.3), radius: 8, y: 4)
        .disabled(viewModel.happinessText.isEmpty || viewModel.isSaving)
        .opacity(viewModel.happinessText.isEmpty ? 0.6 : 1.0)
    }
}

private struct QuickPickSheet: View {
    let onSelect: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selected: Set<String> = []

    private let picks = [
        "ごはんがおいしかった",
        "ちゃんと起きれた",
        "よく眠れた",
        "笑えた瞬間があった",
        "誰かと話せた",
        "好きな曲を聴けた",
        "天気がよかった",
        "がんばって乗り切った",
        "推しに癒された",
        "あったかい飲み物を飲めた",
        "今日も一日過ごせた",
        "深呼吸できた",
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(picks, id: \.self) { pick in
                            let isSelected = selected.contains(pick)
                            Button {
                                if isSelected {
                                    selected.remove(pick)
                                } else {
                                    selected.insert(pick)
                                }
                            } label: {
                                Text(pick)
                                    .font(.subheadline)
                                    .foregroundStyle(isSelected ? .white : Color.appTextPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(isSelected ? Color.appVermillion : Color.appCream)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(isSelected ? Color.appVermillion : Color.appVermillionLight.opacity(0.5), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding()
                }

                Button {
                    let text = picks.filter { selected.contains($0) }.joined(separator: "／")
                    onSelect(text)
                } label: {
                    Text("決定")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.appVermillion)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(selected.isEmpty)
                .opacity(selected.isEmpty ? 0.5 : 1.0)
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("今日できたこと")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                        .foregroundStyle(Color.appVermillion)
                }
            }
        }
    }
}

#Preview {
    InputView(viewModel: MockInputViewModel())
}
