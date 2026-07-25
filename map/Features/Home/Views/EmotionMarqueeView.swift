import SwiftUI

struct EmotionMarqueeView: View {
    let entries: [HappinessEntry]

    @State private var offset: CGFloat = 0

    private let itemWidth: CGFloat = 96
    private let spacing: CGFloat = 24

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "M/d"
        return f
    }()

    var body: some View {
        let setWidth = (itemWidth + spacing) * CGFloat(entries.count)

        GeometryReader { geo in
            let copies = setWidth > 0
                ? max(2, Int((geo.size.width / setWidth).rounded(.up)) + 1)
                : 0

            HStack(spacing: spacing) {
                ForEach(0..<(entries.count * copies), id: \.self) { index in
                    stampItem(entries[index % entries.count])
                        .frame(width: itemWidth)
                }
            }
            .offset(x: offset)
            .onAppear {
                offset = 0
                withAnimation(
                    .linear(duration: Double(entries.count) * 1.4)
                    .repeatForever(autoreverses: false)
                ) {
                    offset = -setWidth
                }
            }
        }
        .frame(height: 130)
        .clipped()
    }

    private func stampItem(_ entry: HappinessEntry) -> some View {
        VStack(spacing: 8) {
            Image(entry.emotionIconId)
                .resizable()
                .scaledToFit()
                .frame(width: 88, height: 88)

            Text(dateFormatter.string(from: entry.date))
                .font(.zenMaru(14, weight: .medium))
                .foregroundStyle(Color.appTextSecondary)
        }
    }
}

#Preview {
    let entries = (0..<4).map { i in
        HappinessEntry(
            date: Calendar.current.date(byAdding: .day, value: -i, to: Date())!,
            emotionIconId: "emotion_\((i % 4) + 1)",
            happinessText: ""
        )
    }
    return ZStack {
        Color.appBackground.ignoresSafeArea()
        EmotionMarqueeView(entries: entries)
    }
}
