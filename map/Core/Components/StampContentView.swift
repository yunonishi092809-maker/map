import SwiftUI

struct StampContentView: View {
    let stamp: StampData

    var body: some View {
        switch stamp.type {
        case .text:
            Text(stamp.text)
                .font(.zenMaru(16, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: .black.opacity(0.3), radius: 4)

        case .music:
            label(icon: "music.note", text: stamp.text)

        case .location:
            label(icon: "mappin.circle.fill", text: stamp.text)
        }
    }

    private func label(icon: String, text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
            Text(text)
                .font(.zenMaru(14, weight: .bold))
                .lineLimit(1)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.appVermillion.opacity(0.9))
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.25), radius: 4)
    }
}

#Preview {
    ZStack {
        Color.gray
        VStack(spacing: 16) {
            StampContentView(stamp: StampData(type: .text, text: "今日は最高！"))
            StampContentView(stamp: StampData(type: .music, text: "群青 / YOASOBI"))
            StampContentView(stamp: StampData(type: .location, text: "渋谷"))
        }
    }
}
