import SwiftUI
import MapKit

struct FullScreenMapView: View {
    let entries: [HappinessEntry]
    @Environment(\.dismiss) private var dismiss
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)

    var body: some View {
        ZStack {
            Map(position: $position) {
                UserAnnotation()

                ForEach(entries.filter { $0.latitude != nil && $0.longitude != nil }) { entry in
                    Annotation("", coordinate: CLLocationCoordinate2D(
                        latitude: entry.latitude!,
                        longitude: entry.longitude!
                    )) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(Color.appVermillion)
                            .font(.title)
                    }
                }
            }
            .ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appVermillion)
                            .frame(width: 36, height: 36)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)
                    }
                    .padding()
                }
                Spacer()
            }
        }
    }
}

#Preview {
    FullScreenMapView(entries: [])
}
