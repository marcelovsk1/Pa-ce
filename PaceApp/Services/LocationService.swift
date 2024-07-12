import Foundation
import CoreLocation
import MapKit

class LocationService: NSObject, CLLocationManagerDelegate, ObservableObject {
    private var locationManager = CLLocationManager()
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), // Los Angeles as default region
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @Published var distance: Double = 0.0
    @Published var routeCoordinates: [CLLocationCoordinate2D] = []
    @Published var speeds: [CLLocationSpeed] = []
    private var lastLocation: CLLocation?
    private var lastUpdateTimestamp: Date?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 10 // Updates every 10 meters
        locationManager.allowsBackgroundLocationUpdates = true // Allow background updates
        locationManager.pausesLocationUpdatesAutomatically = false // Do not pause updates automatically
        checkLocationAuthorization()
    }

    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        case .denied, .restricted:
            print("Location access denied.")
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        @unknown default:
            locationManager.requestAlwaysAuthorization()
        }
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        // Throttle updates to avoid too frequent updates
        let now = Date()
        if let lastUpdate = lastUpdateTimestamp, now.timeIntervalSince(lastUpdate) < 10 {
            return // Skip update if less than 10 seconds have passed
        }
        lastUpdateTimestamp = now

        // Calculate the distance traveled from the last known location
        if let lastLocation = lastLocation {
            let distanceIncrement = newLocation.distance(from: lastLocation)
            distance += distanceIncrement / 1000 // Convert to kilometers
        }

        lastLocation = newLocation

        // Update the map region on the main thread
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(
                center: newLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            self.routeCoordinates.append(newLocation.coordinate)
            self.speeds.append(newLocation.speed)
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }

    func resetData() {
        self.routeCoordinates = []
        self.distance = 0.0
        self.lastLocation = nil
        self.speeds = []
    }
}
