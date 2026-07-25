import SwiftUI

struct EntryCardView: View {
    let entry: HappinessEntry

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日(E)"
        return formatter
    }()

    private var emotionImageName: String {
        entry.emotionIconId
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(dateFormatter.string(from: entry.date))
                    .font(.appSubheadline)
                    .foregroundStyle(Color.appVermillion)

                Spacer()

                emotionBadge
            }

            if !entry.photoData.isEmpty {
                CollageView(photoData: entry.photoData, collageTemplateId: entry.collageTemplateId, stamps: entry.stamps)
            }

            Text(entry.happinessText)
                .font(.appBody)
                .foregroundStyle(Color.appTextPrimary)

            if let locationName = entry.locationName, !locationName.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(Color.appVermillion)
                    Text(locationName)
                        .font(.appCaption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }

            if let musicTitle = entry.musicTitle {
                HStack(spacing: 6) {
                    Image(systemName: "music.note")
                        .foregroundStyle(Color.appVermillion)
                    Text(musicTitle)
                        .font(.appCaption)
                        .foregroundStyle(Color.appTextSecondary)
                    if let artist = entry.musicArtist {
                        Text("- \(artist)")
                            .font(.appCaption)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding()
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appVermillionLight, lineWidth: 1)
        )
    }

    private var emotionBadge: some View {
        Image(emotionImageName)
            .resizable()
            .scaledToFit()
            .frame(width: 32, height: 32)
    }
}

#Preview {
    let entry = HappinessEntry(
        emotionIconId: "happy",
        happinessText: "今日は友達と一緒にお昼ご飯を食べて、とても楽しかった！",
        musicTitle: "群青",
        musicArtist: "YOASOBI",
        locationName: "学校"
    )
    return EntryCardView(entry: entry)
        .padding()
        .background(Color.appBackground)
}
