import SwiftUI

struct WeeklyStampView: View {
    let stamps: [Bool]
    var backgroundImageName: String? = nil
    private let weekdays = ["日", "月", "火", "水", "木", "金", "土"]

    private func stampItem(index: Int) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(stamps[index] ? Color.appVermillion : Color.appVermillionLight.opacity(0.4))
                    .frame(width: 40, height: 40)

                if stamps[index] {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                } else {
                    Circle()
                        .stroke(Color.appVermillionLight, lineWidth: 1.5)
                        .frame(width: 40, height: 40)
                }
            }

            Text(weekdays[index])
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(stamps[index] ? Color.appVermillion : Color.appVermillionLight)
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("今週のスタンプ")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color.appVermillion)
                .padding(.top, 8)

            VStack(spacing: 12) {
                // 上段: 日〜水（4日分）
                HStack(spacing: 16) {
                    ForEach(0..<4, id: \.self) { index in
                        stampItem(index: index)
                    }
                }

                // 下段: 木〜土（3日分）
                HStack(spacing: 16) {
                    ForEach(4..<7, id: \.self) { index in
                        stampItem(index: index)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            GeometryReader { geometry in
                ZStack {
                    if let imageName = backgroundImageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()

                        Color.white.opacity(0.3)
                    } else {
                        Color.white
                    }
                }
            }
        )
        .aspectRatio(2.0, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appVermillionLight.opacity(0.5), lineWidth: 1)
        )
    }
}

#Preview("Default") {
    WeeklyStampView(stamps: [true, true, false, true, false, false, false])
        .padding()
        .background(Color.appBackground)
}

#Preview("Custom Background") {
    WeeklyStampView(
        stamps: [true, true, false, true, false, false, false],
        backgroundImageName: "stampCardBackground"
    )
    .padding()
    .background(Color.appBackground)
}
