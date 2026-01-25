import SwiftUI
import SwiftData

struct InputView<ViewModel: InputViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showPraiseCard = false
    @State private var savedHappinessText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Image("background2")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                Color.white.opacity(0.5)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        topicSection

                        happinessInputSection

                        PositivitySliderView(value: $viewModel.positivityLevel)
                            .padding(.horizontal)

                        LocationPickerView(
                            locationName: $viewModel.locationName,
                            isLoadingLocation: .constant(viewModel.isLoadingLocation),
                            onRequestCurrentLocation: {
                                Task {
                                    await viewModel.fetchLocation()
                                }
                            }
                        )
                        .padding(.horizontal)

                        MusicPickerView(title: $viewModel.musicTitle, artist: $viewModel.musicArtist)
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
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appVermillionLight, lineWidth: 1)
        )
        .padding(.horizontal)
    }

    private var happinessInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日の幸せ")
                .font(.headline)
                .foregroundStyle(Color.appVermillion)

            TextEditor(text: $viewModel.happinessText)
                .frame(minHeight: 120)
                .scrollContentBackground(.hidden)
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.appVermillionLight.opacity(0.5), lineWidth: 1)
                )
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appVermillionLight, lineWidth: 1)
        )
        .padding(.horizontal)
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
        .background(Color.appGold)
        .clipShape(Capsule())
        .shadow(color: Color.appGold.opacity(0.3), radius: 8, y: 4)
        .disabled(viewModel.happinessText.isEmpty || viewModel.isSaving)
        .opacity(viewModel.happinessText.isEmpty ? 0.6 : 1.0)
    }
}

#Preview {
    InputView(viewModel: MockInputViewModel())
}
