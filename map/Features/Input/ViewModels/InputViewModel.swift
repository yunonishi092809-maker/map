import Foundation
import SwiftUI
import SwiftData
import CoreLocation
import Combine

enum InputStep: Int, CaseIterable {
    case emotion = 0
    case detail = 1
    case template = 2
    case edit = 3

    var title: String {
        switch self {
        case .emotion: return "気持ち"
        case .detail: return "詳細"
        case .template: return "テンプレート"
        case .edit: return "編集"
        }
    }
}

protocol InputViewModelProtocol: ObservableObject {
    var currentStep: InputStep { get set }
    var emotionIconId: String { get set }
    var happinessText: String { get set }
    var musicTitle: String { get set }
    var musicArtist: String { get set }
    var selectedMusic: MusicItem? { get set }
    var locationName: String { get set }
    var isLoadingLocation: Bool { get }
    var selectedPhotos: [Data] { get set }
    var selectedTemplateId: String? { get set }
    var stamps: [StampData] { get set }
    var isSaving: Bool { get }
    func saveEntry(context: ModelContext) async
    func fetchLocation() async
    func canProceed() -> Bool
    func nextStep()
    func previousStep()
}

final class InputViewModel: InputViewModelProtocol {
    @Published var currentStep: InputStep = .emotion
    @Published var emotionIconId: String = ""
    @Published var happinessText: String = ""
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
    @Published var selectedPhotos: [Data] = []
    @Published var selectedTemplateId: String? = CollageTemplate.templates.first?.id
    @Published var stamps: [StampData] = []
    @Published var isSaving: Bool = false

    private var currentLocation: CLLocationCoordinate2D?
    private let locationService: LocationServiceProtocol
    private let dataService: DataServiceProtocol
    private let keyService: KeyServiceProtocol
    private let geocoder = CLGeocoder()

    init(
        locationService: LocationServiceProtocol = LocationService.shared,
        dataService: DataServiceProtocol = DataService.shared,
        keyService: KeyServiceProtocol = KeyService.shared
    ) {
        self.locationService = locationService
        self.dataService = dataService
        self.keyService = keyService
    }

    func canProceed() -> Bool {
        switch currentStep {
        case .emotion:
            return !emotionIconId.isEmpty
        case .detail, .template, .edit:
            return true
        }
    }

    func nextStep() {
        guard let next = InputStep(rawValue: currentStep.rawValue + 1) else { return }
        currentStep = next
    }

    func previousStep() {
        guard let prev = InputStep(rawValue: currentStep.rawValue - 1) else { return }
        currentStep = prev
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
            } catch {}
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
        guard !emotionIconId.isEmpty else { return }

        isSaving = true

        let entry = HappinessEntry(
            emotionIconId: emotionIconId,
            happinessText: happinessText,
            musicTitle: musicTitle.isEmpty ? nil : musicTitle,
            musicArtist: musicArtist.isEmpty ? nil : musicArtist,
            locationName: locationName.isEmpty ? nil : locationName,
            latitude: currentLocation?.latitude,
            longitude: currentLocation?.longitude,
            photoData: selectedPhotos,
            collageTemplateId: selectedTemplateId
        )
        entry.stamps = stamps

        dataService.saveEntry(entry, context: context)

        let existingKeys = dataService.fetchKeys(context: context)
        keyService.generateKeysForEntries([entry], existingKeys: existingKeys, context: context)

        isSaving = false
    }
}

final class MockInputViewModel: InputViewModelProtocol {
    @Published var currentStep: InputStep = .emotion
    @Published var emotionIconId: String = ""
    @Published var happinessText: String = ""
    @Published var musicTitle: String = ""
    @Published var musicArtist: String = ""
    @Published var selectedMusic: MusicItem?
    @Published var locationName: String = ""
    @Published var isLoadingLocation: Bool = false
    @Published var selectedPhotos: [Data] = []
    @Published var selectedTemplateId: String?
    @Published var stamps: [StampData] = []
    @Published var isSaving: Bool = false

    func saveEntry(context: ModelContext) async {}
    func fetchLocation() async {}
    func canProceed() -> Bool { true }
    func nextStep() {
        if let next = InputStep(rawValue: currentStep.rawValue + 1) { currentStep = next }
    }
    func previousStep() {
        if let prev = InputStep(rawValue: currentStep.rawValue - 1) { currentStep = prev }
    }
}
