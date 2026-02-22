import SwiftUI

struct WeeklyReviewView: View {
    let entries: [HappinessEntry]
    @Environment(\.dismiss) private var dismiss

    private var weekDateRange: String {
        let calendar = Calendar.current
        let now = Date()
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)),
              let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
            return ""
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d"

        return "\(formatter.string(from: weekStart)) 〜 \(formatter.string(from: weekEnd))"
    }

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
                        headerSection

                        if entries.isEmpty {
                            emptyState
                        } else {
                            ForEach(entries) { entry in
                                EntryCardView(entry: entry)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("今週の振り返り")
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
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Text(weekDateRange)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appVermillion)

            Text("\(entries.count)個の幸せを見つけました！")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)

            if !entries.isEmpty {
                let avgPositivity = entries.reduce(0.0) { $0 + $1.positivityLevel } / Double(entries.count)
                Text("平均ポジティブ度: \(Int(avgPositivity))%")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appVermillionLight, lineWidth: 1)
        )
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundStyle(Color.appVermillionLight)

            Text("今週はまだ記録がありません")
                .font(.headline)
                .foregroundStyle(Color.appTextSecondary)

            Text("幸せを見つけて記録してみよう！")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(.top, 60)
    }
}

#Preview {
    WeeklyReviewView(entries: [])
}
