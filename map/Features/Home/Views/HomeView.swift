import SwiftUI
import SwiftData
import MapKit
import Combine

struct HomeView<ViewModel: HomeViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @Query(sort: \HappinessEntry.date, order: .reverse) private var entries: [HappinessEntry]
    @Query private var keys: [Key]
    @State private var showProfileSheet = false
    @State private var showCalendarSheet = false
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var showKeyCollected = false
    @State private var route: MKRoute?
    @StateObject private var profileViewModel = ProfileViewModel()
    @Environment(\.modelContext) private var modelContext

    private var uncollectedKeys: [Key] {
        keys.filter { !$0.isCollected }
    }

    private struct EntryCluster: Identifiable {
        let id: String
        let coordinate: CLLocationCoordinate2D
        let count: Int
    }

    private var entryClusters: [EntryCluster] {
        let located = entries.filter { $0.latitude != nil && $0.longitude != nil }
        var grouped: [String: (lat: Double, lon: Double, count: Int)] = [:]
        for entry in located {
            let lat = (entry.latitude! * 10000).rounded() / 10000
            let lon = (entry.longitude! * 10000).rounded() / 10000
            let key = "\(lat),\(lon)"
            if let existing = grouped[key] {
                grouped[key] = (existing.lat, existing.lon, existing.count + 1)
            } else {
                grouped[key] = (lat, lon, 1)
            }
        }
        return grouped.map { key, value in
            EntryCluster(
                id: key,
                coordinate: CLLocationCoordinate2D(latitude: value.lat, longitude: value.lon),
                count: value.count
            )
        }
    }

    var body: some View {
        ZStack {
            mapView

            VStack {
                topBar
                    .padding(.horizontal)
                    .padding(.top, 8)

                Spacer()

                HStack {
                    Spacer()
                    currentLocationButton
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 110)
            }

            if showKeyCollected {
                KeyCollectedView {
                    withAnimation(.easeOut(duration: 0.25)) {
                        showKeyCollected = false
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.4), value: showKeyCollected)
        .onAppear {
            viewModel.refreshTimeMode()
            profileViewModel.loadProfile(context: modelContext)
            resetLegacyKeyStockIfNeeded()
            generateKeys()
            LocationService.shared.startMonitoring()
            if viewModel.shouldFocusOnKeys {
                viewModel.shouldFocusOnKeys = false
                Task { await focusNearestKey() }
            }
            if let coordinate = viewModel.focusCoordinate {
                viewModel.focusCoordinate = nil
                focusOn(coordinate)
            }
        }
        .onDisappear {
            LocationService.shared.stopMonitoring()
        }
        .sheet(isPresented: $showProfileSheet) {
            ProfileView(viewModel: profileViewModel)
        }
        .sheet(isPresented: $showCalendarSheet) {
            CalendarStampSheet(entries: entries)
        }
    }

    private var mapView: some View {
        Map(position: $position) {
            UserAnnotation()

            ForEach(entryClusters) { cluster in
                Annotation("", coordinate: cluster.coordinate, anchor: .bottom) {
                    MapPinView(count: cluster.count)
                }
            }

            ForEach(uncollectedKeys) { key in
                Annotation("", coordinate: CLLocationCoordinate2D(
                    latitude: key.latitude,
                    longitude: key.longitude
                )) {
                    KeyAnnotationView()
                        .onTapGesture {
                            collectKey(key)
                        }
                }
            }

            if let route {
                MapPolyline(route.polyline)
                    .stroke(Color.appVermillion, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
            }
        }
        .ignoresSafeArea()
    }

    private var topBar: some View {
        HStack {
            profileButton

            Spacer()

            calendarButton
        }
        .padding(.horizontal, 24)
    }

    private var currentLocationButton: some View {
        Button {
            recenterToCurrentLocation()
        } label: {
            Image(systemName: "location.fill")
                .font(.title3)
                .foregroundStyle(Color.appVermillion)
                .frame(width: 52, height: 52)
                .background(Color.white)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
                .shadow(color: Color.black.opacity(0.15), radius: 6, y: 3)
        }
    }

    private var profileButton: some View {
        Button {
            showProfileSheet = true
        } label: {
            Group {
                if let data = profileViewModel.iconImageData,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 52, height: 52)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                        .frame(width: 52, height: 52)
                        .background(Color.tabButtonBlue)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
            }
            .shadow(color: Color.tabButtonBlue.opacity(0.25), radius: 6, y: 3)
        }
    }

    private var calendarButton: some View {
        Button {
            showCalendarSheet = true
        } label: {
            Image(systemName: "calendar")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(Color.tabButtonBlue)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
                .shadow(color: Color.tabButtonBlue.opacity(0.25), radius: 6, y: 3)
        }
    }

    private func generateKeys() {
        KeyService.shared.generateKeysForEntries(entries, existingKeys: keys, context: modelContext)
    }

    private func resetLegacyKeyStockIfNeeded() {
        let flag = "didResetKeyStock_v1"
        guard !UserDefaults.standard.bool(forKey: flag) else { return }
        for key in keys where key.isCollected && !key.isUsed {
            key.isUsed = true
        }
        try? modelContext.save()
        UserDefaults.standard.set(true, forKey: flag)
    }

    private func focusOn(_ coordinate: CLLocationCoordinate2D) {
        withAnimation(.easeInOut(duration: 0.6)) {
            position = .region(MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
    }

    private func recenterToCurrentLocation() {
        if let coordinate = LocationService.shared.currentCoordinate {
            focusOn(coordinate)
        } else {
            Task {
                if let coordinate = await LocationService.shared.getCurrentLocation() {
                    focusOn(coordinate)
                }
            }
        }
    }

    private func collectKey(_ key: Key) {
        guard !showKeyCollected else { return }
        KeyService.shared.collect(key, context: modelContext)
        route = nil
        showKeyCollected = true
    }

    private func focusNearestKey() async {
        let targets = uncollectedKeys
        guard !targets.isEmpty else { return }

        let userCoord = await LocationService.shared.getCurrentLocation()

        let nearest: Key
        if let userCoord {
            let userLocation = CLLocation(latitude: userCoord.latitude, longitude: userCoord.longitude)
            nearest = targets.min {
                userLocation.distance(from: CLLocation(latitude: $0.latitude, longitude: $0.longitude)) <
                userLocation.distance(from: CLLocation(latitude: $1.latitude, longitude: $1.longitude))
            } ?? targets[0]
        } else {
            nearest = targets[0]
        }

        let coordinate = CLLocationCoordinate2D(latitude: nearest.latitude, longitude: nearest.longitude)

        if let userCoord, let route = await calculateRoute(from: userCoord, to: coordinate) {
            self.route = route
            let padded = route.polyline.boundingMapRect.insetBy(
                dx: -route.polyline.boundingMapRect.size.width * 0.25,
                dy: -route.polyline.boundingMapRect.size.height * 0.25
            )
            withAnimation(.easeInOut(duration: 0.6)) {
                position = .rect(padded)
            }
        } else {
            focusOn(coordinate)
        }
    }

    private func calculateRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) async -> MKRoute? {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .walking
        let directions = MKDirections(request: request)
        let response = try? await directions.calculate()
        return response?.routes.first
    }
}

// MARK: - Calendar + Stamp Sheet

private struct CalendarStampSheet: View {
    let entries: [HappinessEntry]
    @Environment(\.dismiss) private var dismiss

    private var entryDates: Set<Date> {
        let calendar = Calendar.current
        return Set(entries.map { calendar.startOfDay(for: $0.date) })
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appPageBackground
                    .ignoresSafeArea(.all)

                GeometryReader { geo in
                    VStack(spacing: 16) {
                        CalendarView(entryDates: entryDates)
                            .frame(height: geo.size.height * 0.7)
                            .padding(.horizontal)

                        recentEmotionsSection

                        Spacer(minLength: 0)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("カレンダー")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: { Text("Close").font(.squadaOne(17)) }
                        .foregroundStyle(Color.appVermillion)
                }
            }
        }
    }

    private var loopEntries: [HappinessEntry] {
        entries.sorted { $0.date > $1.date }
    }

    private var recentEmotionsSection: some View {
        Group {
            if !loopEntries.isEmpty {
                EmotionMarqueeView(entries: loopEntries)
            }
        }
    }
}

#Preview("Morning") {
    HomeView(viewModel: MockHomeViewModel())
}
