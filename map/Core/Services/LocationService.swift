import Foundation
import CoreLocation

protocol LocationServiceProtocol {
    func requestPermission()
    func getCurrentLocation() async -> CLLocationCoordinate2D?
}

final class LocationService: NSObject, LocationServiceProtocol {
    static let shared = LocationService()

    private let locationManager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocationCoordinate2D?, Never>?

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func getCurrentLocation() async -> CLLocationCoordinate2D? {
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            locationManager.requestLocation()
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
