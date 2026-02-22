import Foundation
import SwiftUI
import SwiftData
import CoreLocation
import Combine

protocol InputViewModelProtocol: ObservableObject {
    var happinessText: String { get set }
    var positivityLevel: Double { get set }
    var musicTitle: String { get set }
    var musicArtist: String { get set }
    var selectedMusic: MusicItem? { get set }
    var locationName: String { get set }
    var isLoadingLocation: Bool { get }
    var currentTopic: Topic { get }
    var isSaving: Bool { get }
    func saveEntry(context: ModelContext) async
    func fetchLocation() async
}

final class InputViewModel: InputViewModelProtocol {
    @Published var happinessText: String = ""
    @Published var positivityLevel: Double = 50
    @Published var musicTitle: String = ""
    @Published var musicArtist: String = ""
    @Published var selectedMusic: MusicItem? {
        didSet {
            if let music = selectedMusic {
                musicTitle = music.title
                musicArtist = music.artistName
            } else {
                musicTitle = ""
                musicArtist = ""
            }
        }
    }
    @Published var locationName: String = ""
    @Published var isLoadingLocation: Bool = false
    @Published var currentTopic: Topic
    @Published var isSaving: Bool = false

    private var currentLocation: CLLocationCoordinate2D?
    private let locationService: LocationServiceProtocol
    private let dataService: DataServiceProtocol
    private let geocoder = CLGeocoder()

    init(
        locationService: LocationServiceProtocol = LocationService.shared,
        dataService: DataServiceProtocol = DataService.shared
    ) {
        self.locationService = locationService
        self.dataService = dataService
        self.currentTopic = Topic.todaysTopic()
    }

    @MainActor
    func fetchLocation() async {
        isLoadingLocation = true
        locationService.requestPermission()
        currentLocation = await locationService.getCurrentLocation()

        if let coordinate = currentLocation {
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                if let placemark = placemarks.first {
                    locationName = buildLocationName(from: placemark)
                }
            } catch {
                // Geocoding failed, keep manual input
            }
        }
        isLoadingLocation = false
    }

    private func buildLocationName(from placemark: CLPlacemark) -> String {
        var components: [String] = []
        if let name = placemark.name, name != placemark.locality {
            components.append(name)
        }
        if let locality = placemark.locality {
            components.append(locality)
        }
        return components.joined(separator: "、")
    }

    @MainActor
    func saveEntry(context: ModelContext) async {
        guard !happinessText.isEmpty else { return }

        isSaving = true

        let entry = HappinessEntry(
            topicId: currentTopic.id,
            happinessText: happinessText,
            positivityLevel: positivityLevel,
            musicTitle: musicTitle.isEmpty ? nil : musicTitle,
            musicArtist: musicArtist.isEmpty ? nil : musicArtist,
            locationName: locationName.isEmpty ? nil : locationName,
            latitude: currentLocation?.latitude,
            longitude: currentLocation?.longitude
        )

        dataService.saveEntry(entry, context: context)
        isSaving = false
    }
}

final class MockInputViewModel: InputViewModelProtocol {
    @Published var happinessText: String = ""
    @Published var positivityLevel: Double = 50
    @Published var musicTitle: String = ""
    @Published var musicArtist: String = ""
    @Published var selectedMusic: MusicItem?
    @Published var locationName: String = ""
    @Published var isLoadingLocation: Bool = false
    @Published var currentTopic: Topic = Topic.defaultTopics[0]
    @Published var isSaving: Bool = false

    func saveEntry(context: ModelContext) async {}
    func fetchLocation() async {}
}
