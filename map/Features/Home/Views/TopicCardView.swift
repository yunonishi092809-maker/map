import SwiftUI

struct TopicCardView: View {
    let topic: Topic

    var body: some View {
        VStack(spacing: 12) {
            Text("今日のお題")
                .font(.headline)
                .foregroundStyle(Color.appVermillion)

            Text(topic.question)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(3)

            Text(topic.hint)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.appVermillionLight, lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
    }
}

#Preview {
    TopicCardView(topic: Topic.defaultTopics[0])
        .padding()
        .background(Color.appBackground)
}
