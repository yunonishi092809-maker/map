import SwiftUI

struct MusicPickerView: View {
    @Binding var title: String
    @Binding var artist: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日の1曲")
                .font(.headline)
                .foregroundStyle(Color.appVermillion)

            TextField("曲名", text: $title)
                .textFieldStyle(.plain)
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.appVermillionLight.opacity(0.5), lineWidth: 1)
                )

            TextField("アーティスト名", text: $artist)
                .textFieldStyle(.plain)
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.appVermillionLight.opacity(0.5), lineWidth: 1)
                )
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appVermillionLight, lineWidth: 1)
        )
    }
}

#Preview {
    MusicPickerView(title: .constant(""), artist: .constant(""))
        .padding()
        .background(Color.appBackground)
}
