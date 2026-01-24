import SwiftUI

struct EntryCardView: View {
    let entry: HappinessEntry

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日(E)"
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(dateFormatter.string(from: entry.date))
                    .font(.subheadline)
                    .foregroundStyle(Color.appVermillion)

                Spacer()

                positivityBadge
            }

            Text(entry.happinessText)
                .font(.body)
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(3)

            if let locationName = entry.locationName, !locationName.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(Color.appVermillion)
                    Text(locationName)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }

            if let musicTitle = entry.musicTitle {
                HStack(spacing: 6) {
                    Image(systemName: "music.note")
                        .foregroundStyle(Color.appVermillion)
                    Text(musicTitle)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                    if let artist = entry.musicArtist {
                        Text("- \(artist)")
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appVermillionLight, lineWidth: 1)
        )
    }

    private var positivityBadge: some View {
        Text("\(Int(entry.positivityLevel))%")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.appVermillion)
            .clipShape(Capsule())
    }
}

#Preview {
    let entry = HappinessEntry(
        topicId: "1",
        happinessText: "今日は友達と一緒にお昼ご飯を食べて、とても楽しかった！",
        positivityLevel: 80,
        musicTitle: "群青",
        musicArtist: "YOASOBI",
        locationName: "学校"
    )
    return EntryCardView(entry: entry)
        .padding()
        .background(Color.appBackground)
}
