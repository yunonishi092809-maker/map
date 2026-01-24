import SwiftUI
import SwiftData

struct ProfileView<ViewModel: ProfileViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @Query(sort: \HappinessEntry.date, order: .reverse) private var entries: [HappinessEntry]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        profileHeader

                        streakCard

                        CalendarView(entryDates: viewModel.getEntryDates(entries: entries))
                            .padding(.horizontal)

                        statsSection
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("プロフィール")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.appVermillion)

            Text(viewModel.userName)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appTextPrimary)
        }
        .padding(.top)
    }

    private var streakCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "flame.fill")
                .font(.title)
                .foregroundStyle(Color.appVermillion)

            VStack(alignment: .leading) {
                Text("継続日数")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)

                Text("\(viewModel.calculateStreak(entries: entries))日")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appVermillion)
            }

            Spacer()
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

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("統計")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
                .padding(.horizontal)

            HStack(spacing: 16) {
                statCard(title: "記録数", value: "\(entries.count)", icon: "heart.fill", color: Color.appVermillion)
                statCard(title: "平均ポジ度", value: averagePositivity, icon: "face.smiling.fill", color: Color.appGold)
            }
            .padding(.horizontal)
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color.appTextPrimary)

            Text(title)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appVermillionLight, lineWidth: 1)
        )
    }

    private var averagePositivity: String {
        guard !entries.isEmpty else { return "0%" }
        let average = entries.reduce(0.0) { $0 + $1.positivityLevel } / Double(entries.count)
        return "\(Int(average))%"
    }
}

#Preview {
    ProfileView(viewModel: MockProfileViewModel())
}
