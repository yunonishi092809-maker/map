import SwiftUI
import CoreLocation

struct LocationPickerView: View {
    @Binding var locationName: String
    @Binding var isLoadingLocation: Bool
    let onRequestCurrentLocation: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("場所")
                    .font(.headline)
                    .foregroundStyle(Color.appVermillion)

                Spacer()

                Button {
                    onRequestCurrentLocation()
                } label: {
                    HStack(spacing: 4) {
                        if isLoadingLocation {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "location.fill")
                        }
                        Text("現在地を取得")
                            .font(.caption)
                    }
                    .foregroundStyle(Color.appVermillion)
                }
                .disabled(isLoadingLocation)
            }

            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundStyle(Color.appVermillion)

                TextField("場所を入力（例：学校、カフェ、自宅）", text: $locationName)
                    .textFieldStyle(.plain)
            }
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
    LocationPickerView(
        locationName: .constant(""),
        isLoadingLocation: .constant(false),
        onRequestCurrentLocation: {}
    )
    .padding()
    .background(Color.appBackground)
}
