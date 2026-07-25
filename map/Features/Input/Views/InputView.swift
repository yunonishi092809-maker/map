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
                Color.appPageBackground
                    .ignoresSafeArea(.all)

                VStack(spacing: 0) {
                    stepIndicator
                        .padding(.top, 8)

                    Spacer(minLength: 0)

                    stepContent

                    Spacer(minLength: 0)

                    if viewModel.currentStep != .edit {
                        navigationButtons
                            .padding(.bottom, 16)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Close")
                            .font(.squadaOne(17))
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
                PraiseCardView(emotionIconId: viewModel.emotionIconId, happinessText: savedHappinessText) {
                    dismiss()
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.spring(response: 0.4), value: showPraiseCard)
    }

    private var stepIndicator: some View {
        HStack(spacing: 8) {
            ForEach(InputStep.allCases, id: \.rawValue) { step in
                Capsule()
                    .fill(step.rawValue <= viewModel.currentStep.rawValue
                          ? Color.appVermillion
                          : Color.appVermillionLight.opacity(0.4))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case .emotion:
            EmotionStepView(selectedEmotionId: $viewModel.emotionIconId)
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

        case .detail:
            DetailStepView(viewModel: viewModel)
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

        case .template:
            TemplateStepView(selectedTemplateId: $viewModel.selectedTemplateId)
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

        case .edit:
            EditStepView(
                selectedPhotos: $viewModel.selectedPhotos,
                templateId: viewModel.selectedTemplateId,
                happinessText: viewModel.happinessText,
                musicTitle: viewModel.musicTitle,
                musicArtist: viewModel.musicArtist,
                locationName: viewModel.locationName,
                stamps: $viewModel.stamps,
                isSaving: viewModel.isSaving,
                onSave: {
                    Task {
                        savedHappinessText = viewModel.happinessText
                        await viewModel.saveEntry(context: modelContext)
                        showPraiseCard = true
                    }
                },
                onBack: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.previousStep()
                    }
                }
            )
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        }
    }

    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if viewModel.currentStep == .template {
                saveButton
            } else if viewModel.currentStep != .emotion {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.previousStep()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                            .font(.squadaOne(17))
                    }
                    .font(.appHeadline)
                    .foregroundStyle(Color.appVermillion)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.appCardBackground)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.appVermillionLight, lineWidth: 1)
                    )
                }
            }

            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.nextStep()
                }
            } label: {
                HStack(spacing: 4) {
                    Text("Next")
                        .font(.squadaOne(17))
                    Image(systemName: "chevron.right")
                }
                .font(.appHeadline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(viewModel.canProceed() ? Color.appVermillion : Color.appVermillionLight)
                .clipShape(Capsule())
            }
            .disabled(!viewModel.canProceed())
        }
        .padding(.horizontal, 60)
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
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.appVermillion)
                    .clipShape(Capsule())
            } else {
                Text("Save")
                    .font(.squadaOne(17))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.appVermillion)
                    .clipShape(Capsule())
            }
        }
        .disabled(viewModel.isSaving)
    }
}

#Preview {
    InputView(viewModel: MockInputViewModel())
}
