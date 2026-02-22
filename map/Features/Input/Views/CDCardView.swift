import SwiftUI

struct CDCardView: View {
    let music: MusicItem
    let size: CGFloat

    init(music: MusicItem, size: CGFloat = 140) {
        self.music = music
        self.size = size
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // CD outer ring
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.appVermillionLight,
                                Color.appVermillionLight.opacity(0.6),
                                Color.appVermillionLight.opacity(0.8),
                                Color.appVermillionLight
                            ],
                            center: .center,
                            startRadius: size * 0.3,
                            endRadius: size * 0.5
                        )
                    )
                    .frame(width: size, height: size)

                // Artwork
                if let url = music.artworkURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            artworkPlaceholder
                        case .empty:
                            ProgressView()
                                .frame(width: size * 0.7, height: size * 0.7)
                        @unknown default:
                            artworkPlaceholder
                        }
                    }
                    .frame(width: size * 0.7, height: size * 0.7)
                    .clipShape(Circle())
                } else {
                    artworkPlaceholder
                }

                // Center hole
                Circle()
                    .fill(Color.appVermillion)
                    .frame(width: size * 0.1, height: size * 0.1)
            }

            Text(music.title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)

            Text(music.artistName)
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(1)
        }
        .frame(width: size)
    }

    private var artworkPlaceholder: some View {
        Circle()
            .fill(Color.appCream)
            .frame(width: size * 0.7, height: size * 0.7)
            .overlay(
                Image(systemName: "music.note")
                    .font(.system(size: size * 0.2))
                    .foregroundStyle(Color.appVermillionLight)
            )
    }
}

#Preview {
    HStack(spacing: 16) {
        CDCardView(
            music: MusicItem(
                id: "1",
                title: "夜に駆ける",
                artistName: "YOASOBI",
                artworkURL: nil
            )
        )

        CDCardView(
            music: MusicItem(
                id: "2",
                title: "Shape of You",
                artistName: "Ed Sheeran",
                artworkURL: nil
            ),
            size: 120
        )
    }
    .padding()
    .background(Color.appBackground)
}
