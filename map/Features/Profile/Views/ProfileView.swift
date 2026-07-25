import SwiftUI
import SwiftData

struct ProfileView<ViewModel: ProfileViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \HappinessEntry.date, order: .reverse) private var entries: [HappinessEntry]
    @State private var showEditSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appPageBackground
                    .ignoresSafeArea(.all)

                ScrollView {
                    VStack(spacing: 12) {
                        profileHeader

                        WeeklyStampView(stamps: weeklyStamps)
                            .padding(.horizontal)

                        statsSection
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("プロフィール")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: { Text("Close").font(.squadaOne(17)) }
                        .foregroundStyle(Color.appVermillion)
                }
            }
            .sheet(isPresented: $showEditSheet) {
                ProfileEditView(viewModel: viewModel)
            }
            .task {
                viewModel.loadProfile(context: modelContext)
            }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 10) {
            profileIcon
                .overlay(alignment: .bottomTrailing) {
                    pencilBadge
                }
                .onTapGesture {
                    showEditSheet = true
                }

            HStack(spacing: 6) {
                Text(viewModel.userName)
                    .font(.appTitle)
                    .foregroundStyle(Color.appTextPrimary)

                Image(systemName: "pencil")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
            }
            .onTapGesture {
                showEditSheet = true
            }

            streakBadge
        }
        .padding(.top, 24)
    }

    private var streakBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .font(.title3)
                .foregroundStyle(Color.appVermillion)

            Text("\(viewModel.calculateStreak(entries: entries))日")
                .font(.zenMaru(20, weight: .bold))
                .foregroundStyle(Color.appVermillion)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
        .background(Color.appVermillion.opacity(0.12))
        .clipShape(Capsule())
    }

    private var pencilBadge: some View {
        Circle()
            .fill(Color.appCardBackground)
            .frame(width: 30, height: 30)
            .overlay(
                Image(systemName: "pencil")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appVermillion)
            )
            .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
    }

    @ViewBuilder
    private var profileIcon: some View {
        if let data = viewModel.iconImageData,
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
        } else {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 120))
                .foregroundStyle(Color.appVermillion)
        }
    }

    private var weeklyStamps: [Bool] {
        let calendar = Calendar.current
        let now = Date()
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else {
            return Array(repeating: false, count: 7)
        }
        let dates = Set(entries.map { calendar.startOfDay(for: $0.date) })
        return (0..<7).map { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else {
                return false
            }
            return dates.contains(calendar.startOfDay(for: date))
        }
    }

    private var statsSection: some View {
        HStack(spacing: 12) {
            statCard(title: "記録数", value: "\(entries.count)", icon: "heart.fill", color: Color.appVermillion)
        }
        .padding(.horizontal)
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .symbolRenderingMode(.palette)
                .foregroundStyle(color, .white)

            Text(value)
                .font(.appTitle2)
                .foregroundStyle(Color.appTextPrimary)

            Text(title)
                .font(.appCaption)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appVermillionLight, lineWidth: 1)
        )
    }
}

#Preview {
    ProfileView(viewModel: MockProfileViewModel())
        .modelContainer(for: [UserProfile.self, HappinessEntry.self], inMemory: true)
}
