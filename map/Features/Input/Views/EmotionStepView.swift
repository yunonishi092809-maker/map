import SwiftUI

struct EmotionIcon: Identifiable {
    let id: String
    let imageName: String
}

private let emotionIcons: [EmotionIcon] = [
    EmotionIcon(id: "emotion_1", imageName: "emotion_1"),
    EmotionIcon(id: "emotion_2", imageName: "emotion_2"),
    EmotionIcon(id: "emotion_3", imageName: "emotion_3"),
    EmotionIcon(id: "emotion_4", imageName: "emotion_4"),
]

struct EmotionStepView: View {
    @Binding var selectedEmotionId: String

    var body: some View {
        VStack(spacing: 24) {
            Text("今日はどんな感じ？")
                .font(.appTitle2)
                .foregroundStyle(Color.appTextPrimary)

            LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
        ], spacing: 20) {
            ForEach(emotionIcons) { icon in
                emotionButton(icon)
            }
        }
        .padding(.horizontal, 24)
        }
        .padding()
    }

    private func emotionButton(_ icon: EmotionIcon) -> some View {
        let isSelected = selectedEmotionId == icon.id

        return Button {
            selectedEmotionId = icon.id
        } label: {
            Image(icon.imageName)
                .resizable()
                .scaledToFit()
                .offset(y: icon.id == "emotion_2" ? 6 : 0)
                .padding(-4)
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.tabButtonBlue : Color.tabButtonBlue.opacity(0.3), lineWidth: isSelected ? 5 : 5)
                )
                .scaleEffect(isSelected ? 1.06 : 1.0)
                .animation(.spring(response: 0.3), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    EmotionStepView(selectedEmotionId: .constant("emotion_1"))
        .background(Color.appPageBackground)
}
