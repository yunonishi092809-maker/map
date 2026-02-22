import SwiftUI
import SwiftData

struct ProfileView<ViewModel: ProfileViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HappinessEntry.date, order: .reverse) private var entries: [HappinessEntry]
    @State private var showEditSheet = false

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
                    VStack(spacing: 12) {
                        profileHeader

                        CalendarView(entryDates: viewModel.getEntryDates(entries: entries))
                            .padding(.horizontal)

                        statsSection
                    }
                    .padding(.vertical, 8)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
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
                    .font(.title)
                    .fontWeight(.bold)
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
                .font(.title3)
                .fontWeight(.bold)
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

    private var statsSection: some View {
        HStack(spacing: 12) {
            statCard(title: "記録数", value: "\(entries.count)", icon: "heart.fill", color: Color.appVermillion)
            statCard(title: "平均ポジ度", value: averagePositivity, icon: "sparkles", color: Color.appVermillion)
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
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color.appTextPrimary)

            Text(title)
                .font(.caption)
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

    private var averagePositivity: String {
        guard !entries.isEmpty else { return "0%" }
        let average = entries.reduce(0.0) { $0 + $1.positivityLevel } / Double(entries.count)
        return "\(Int(average))%"
    }
}

#Preview {
    ProfileView(viewModel: MockProfileViewModel())
        .modelContainer(for: [UserProfile.self, HappinessEntry.self], inMemory: true)
}
