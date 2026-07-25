import Foundation
import CoreLocation
import Combine

protocol LocationServiceProtocol {
    func requestPermission()
    func getCurrentLocation() async -> CLLocationCoordinate2D?
}

final class LocationService: NSObject, LocationServiceProtocol, ObservableObject {
    static let shared = LocationService()

    private let locationManager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocationCoordinate2D?, Never>?

    @Published var currentCoordinate: CLLocationCoordinate2D?

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
    }

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startMonitoring() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func stopMonitoring() {
        locationManager.stopUpdatingLocation()
    }

    func getCurrentLocation() async -> CLLocationCoordinate2D? {
        if let currentCoordinate {
            return currentCoordinate
        }
        return await withCheckedContinuation { continuation in
            self.continuation?.resume(returning: nil)
            self.continuation = continuation
            locationManager.requestLocation()
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.last?.coordinate {
            currentCoordinate = coordinate
        }
        continuation?.resume(returning: locations.first?.coordinate)
        continuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(returning: nil)
        continuation = nil
    }
}

final class MockLocationService: LocationServiceProtocol {
    var mockCoordinate: CLLocationCoordinate2D?

    func requestPermission() {}

    func getCurrentLocation() async -> CLLocationCoordinate2D? {
        mockCoordinate
    }
}
