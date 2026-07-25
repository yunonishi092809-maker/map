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
                Color.appPageBackground
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
                    Button {
                        dismiss()
                    } label: {
                        Text("Close").font(.squadaOne(17))
                    }
                    .foregroundStyle(Color.appVermillion)
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Text(weekDateRange)
                .font(.appTitle3)
                .foregroundStyle(Color.appVermillion)

            Text("\(entries.count)個の幸せを見つけました！")
                .font(.appHeadline)
                .foregroundStyle(Color.appTextPrimary)
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
                .font(.appHeadline)
                .foregroundStyle(Color.appTextSecondary)

            Text("幸せを見つけて記録してみよう！")
                .font(.appSubheadline)
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(.top, 60)
    }
}

#Preview {
    WeeklyReviewView(entries: [])
}
