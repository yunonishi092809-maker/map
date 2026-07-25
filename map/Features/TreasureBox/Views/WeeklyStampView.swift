import SwiftUI

struct WeeklyStampView: View {
    let stamps: [Bool]
    var backgroundImageName: String? = nil
    private let weekdays = ["日", "月", "火", "水", "木", "金", "土"]

    private func stampItem(index: Int) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(stamps[index] ? Color.tabButtonBlue : Color.tabButtonBlue.opacity(0.2))
                    .frame(width: 52, height: 52)

                if stamps[index] {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.white)
                } else {
                    Circle()
                        .stroke(Color.tabButtonBlue.opacity(0.4), lineWidth: 1.5)
                        .frame(width: 52, height: 52)
                }
            }

            Text(weekdays[index])
                .font(.zenMaru(12, weight: .medium))
                .foregroundStyle(stamps[index] ? Color.tabButtonBlue : Color.tabButtonBlue.opacity(0.5))
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("今週のスタンプ")
                .font(.zenMaru(15, weight: .medium))
                .foregroundStyle(Color.tabButtonBlue)
                .padding(.top, 8)

            VStack(spacing: 14) {
                HStack(spacing: 12) {
                    ForEach(0..<4, id: \.self) { index in
                        stampItem(index: index)
                    }
                }

                HStack(spacing: 12) {
                    ForEach(4..<7, id: \.self) { index in
                        stampItem(index: index)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.tabButtonBlue.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview("Default") {
    WeeklyStampView(stamps: [true, true, false, true, false, false, false])
        .padding()
        .background(Color.appPageBackground)
}
