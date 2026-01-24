import SwiftUI
import MapKit

struct MapCircleView: View {
    let entries: [HappinessEntry]
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var showFullScreen = false

    var body: some View {
        ZStack {
            Map(position: $position, interactionModes: []) {
                UserAnnotation()

                ForEach(entries.filter { $0.latitude != nil && $0.longitude != nil }) { entry in
                    Annotation("", coordinate: CLLocationCoordinate2D(
                        latitude: entry.latitude!,
                        longitude: entry.longitude!
                    )) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(Color.appVermillion)
                            .font(.title2)
                    }
                }
            }

            Color.clear
                .contentShape(Circle())
                .onTapGesture(count: 2) {
                    showFullScreen = true
                }
        }
        .frame(width: 280, height: 280)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.appVermillion, lineWidth: 4)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, y: 4)
        .fullScreenCover(isPresented: $showFullScreen) {
            FullScreenMapView(entries: entries)
        }
    }
}

#Preview {
    MapCircleView(entries: [])
        .background(Color.appBackground)
}
