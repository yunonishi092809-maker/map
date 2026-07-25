import SwiftUI
import CoreLocation

struct PhotoAlbumView: View {
    let entries: [HappinessEntry]
    var onTapLocation: (CLLocationCoordinate2D) -> Void = { _ in }

    @State private var currentPage = 0
    @State private var flip: FlipState?

    private struct FlipState {
        let from: Int
        let to: Int
        let forward: Bool
        var angle: Double
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日(E)"
        return formatter
    }()

    var body: some View {
        VStack(spacing: 16) {
            book

            pageIndicator

            locationChip
        }
    }

    @ViewBuilder
    private var locationChip: some View {
        if currentPage < entries.count,
           let latitude = entries[currentPage].latitude,
           let longitude = entries[currentPage].longitude,
           let name = entries[currentPage].locationName, !name.isEmpty {
            Button {
                onTapLocation(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                    Text(name)
                        .font(.zenMaru(14, weight: .bold))
                        .lineLimit(1)
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                }
                .foregroundStyle(Color.appVermillion)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.white)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.appVermillion, lineWidth: 1.5))
            }
        }
    }

    private var book: some View {
        GeometryReader { geo in
            ZStack {
                if let flip {
                    pageBoard(entries[flip.forward ? flip.to : flip.from])

                    pageBoard(entries[flip.forward ? flip.from : flip.to])
                        .rotation3DEffect(
                            .degrees(flip.angle),
                            axis: (x: 0, y: 1, z: 0),
                            anchor: .leading,
                            perspective: 0.4
                        )
                        .opacity(flip.angle <= -90 ? 0 : 1)
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 4)
                } else {
                    pageBoard(entries[currentPage])
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .overlay {
                HStack(spacing: 0) {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { goBack() }
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { goNext() }
                }
            }
        }
        .aspectRatio(9 / 16, contentMode: .fit)
        .padding(.horizontal, 36)
    }

    private func pageBoard(_ entry: HappinessEntry) -> some View {
        VStack(spacing: 10) {
            CollageView(photoData: entry.photoData, collageTemplateId: entry.collageTemplateId, stamps: entry.stamps)

            Text(dateFormatter.string(from: entry.date))
                .font(.zenMaru(13, weight: .medium))
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(12)
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.appVermillionLight, lineWidth: 1)
        )
        .overlay(alignment: .leading) {
            LinearGradient(
                colors: [Color.black.opacity(0.06), Color.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 16)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(entries.indices, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.appVermillion : Color.appVermillionLight)
                    .frame(width: index == currentPage ? 10 : 7,
                           height: index == currentPage ? 10 : 7)
            }
        }
        .animation(.spring(response: 0.3), value: currentPage)
    }

    private func goNext() {
        guard flip == nil, entries.count > 1 else { return }
        let target = (currentPage + 1) % entries.count
        flip = FlipState(from: currentPage, to: target, forward: true, angle: 0)
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.55)) {
                flip?.angle = -180
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            currentPage = target
            flip = nil
        }
    }

    private func goBack() {
        guard flip == nil, entries.count > 1 else { return }
        let target = (currentPage - 1 + entries.count) % entries.count
        flip = FlipState(from: currentPage, to: target, forward: false, angle: -180)
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.55)) {
                flip?.angle = 0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            currentPage = target
            flip = nil
        }
    }
}

#Preview {
    let entry = HappinessEntry(
        emotionIconId: "emotion_1",
        happinessText: "楽しかった",
        locationName: "学校"
    )
    return ZStack {
        Color.appBackground.ignoresSafeArea()
        PhotoAlbumView(entries: [entry])
    }
}
