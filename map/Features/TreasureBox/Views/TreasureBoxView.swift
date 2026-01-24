import SwiftUI
import SwiftData

struct TreasureBoxView<ViewModel: TreasureBoxViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @Query(sort: \HappinessEntry.date, order: .reverse) private var entries: [HappinessEntry]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                if viewModel.isBoxOpen {
                    entriesList
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    closedBoxView
                }
            }
            .navigationTitle("宝箱")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var closedBoxView: some View {
        VStack(spacing: 24) {
            Spacer()

            treasureBoxIcon

            Text("タップして宝箱を開ける")
                .font(.headline)
                .foregroundStyle(Color.appVermillion)

            Text("\(entries.count)個の幸せが入っています")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)

            Spacer()
        }
        .onTapGesture {
            viewModel.openBox()
        }
    }

    private var treasureBoxIcon: some View {
        ZStack {
            // Box body
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .frame(width: 140, height: 90)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.appVermillion, lineWidth: 3)
                )
                .shadow(color: Color.appVermillion.opacity(0.2), radius: 12, y: 6)

            // Box lid
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .frame(width: 150, height: 25)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.appVermillion, lineWidth: 3)
                )
                .offset(y: -55)

            // Heart decoration
            Image(systemName: "heart.fill")
                .font(.title2)
                .foregroundStyle(Color.appVermillion)
        }
    }

    private var entriesList: some View {
        VStack {
            Button {
                viewModel.closeBox()
            } label: {
                HStack {
                    Image(systemName: "chevron.down")
                    Text("閉じる")
                }
                .font(.subheadline)
                .foregroundStyle(Color.appVermillion)
            }
            .padding(.top)

            if entries.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(entries) { entry in
                            EntryCardView(entry: entry)
                        }
                    }
                    .padding()
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundStyle(Color.appVermillionLight)

            Text("まだ幸せが入っていません")
                .font(.headline)
                .foregroundStyle(Color.appTextSecondary)

            Text("今日の幸せを記録してみましょう")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)

            Spacer()
        }
    }
}

#Preview("Closed") {
    TreasureBoxView(viewModel: MockTreasureBoxViewModel())
}

#Preview("Open") {
    let vm = MockTreasureBoxViewModel()
    vm.isBoxOpen = true
    return TreasureBoxView(viewModel: vm)
}
