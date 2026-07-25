import SwiftUI

struct DetailStepView<ViewModel: InputViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @FocusState private var isTextEditorFocused: Bool
    @State private var showHintSheet = false

    private let maxCharacterCount = 100

    private let hints = [
        "今日ちゃんと起きれた！",
        "ご飯を食べられた",
        "学校に行けた",
        "友達と話せた",
        "宿題を終わらせた",
        "早起きできた",
        "ちゃんと寝れた",
        "お風呂に入れた",
        "誰かにありがとうって言えた",
        "今日も一日頑張った",
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("今日の一言")
                    .font(.appTitle2)
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(.top, 32)

                textSection

                HStack(spacing: 12) {
                    locationSection
                    musicSection
                }
                .frame(height: 160)
            }
            .padding()
            .padding(.bottom, 12)
        }
    }

    private var textSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("一言メモ")
                    .font(.appHeadline)
                    .foregroundStyle(Color.appVermillion)

                Spacer()

                Text("\(viewModel.happinessText.count)/\(maxCharacterCount)")
                    .font(.appCaption)
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
                            Button {
                                isTextEditorFocused = false
                            } label: {
                                Text("Done").font(.squadaOne(17))
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

            HStack {
                Spacer()
                Button {
                    showHintSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 12))
                        Text("思いつかないときはここをタップ")
                            .font(.appSubheadline)
                    }
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.tabButtonBlue, lineWidth: 2)
                    )
                }
                Spacer()
            }
        }
        .padding()
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appVermillionLight, lineWidth: 1)
        )
        .sheet(isPresented: $showHintSheet) {
            hintSheet
                .presentationDetents([.medium])
        }
    }

    private var hintSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(hints, id: \.self) { hint in
                        Button {
                            viewModel.happinessText = hint
                            showHintSheet = false
                        } label: {
                            Text(hint)
                                .font(.appBody)
                                .foregroundStyle(Color.appTextPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.appCardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.appVermillionLight, lineWidth: 1)
                                )
                        }
                    }
                }
                .padding()
            }
            .background(Color.appPageBackground)
            .navigationTitle("書くヒント")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { showHintSheet = false } label: { Text("Close").font(.squadaOne(17)) }
                        .foregroundStyle(Color.appVermillion)
                }
            }
        }
    }

    private var locationSection: some View {
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
    }

    private var musicSection: some View {
        MusicPickerView(viewModel: viewModel, compact: true)
    }
}

#Preview {
    DetailStepView(viewModel: MockInputViewModel())
        .background(Color.appBackground)
}
