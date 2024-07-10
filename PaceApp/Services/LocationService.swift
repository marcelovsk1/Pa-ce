import Foundation
import CoreLocation
import MapKit

class LocationService: NSObject, CLLocationManagerDelegate, ObservableObject {
    private var locationManager = CLLocationManager()
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), // Los Angeles como exemplo de região padrão
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @Published var distance: Double = 0.0
    @Published var routeCoordinates: [CLLocationCoordinate2D] = []
    private var lastLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 10 // Atualizações a cada 10 metros
        locationManager.allowsBackgroundLocationUpdates = true // Permitir atualizações em segundo plano
        locationManager.pausesLocationUpdatesAutomatically = false // Não pausar atualizações automaticamente
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

        // Calcular a distância percorrida desde a última localização conhecida
        if let lastLocation = lastLocation {
            let distanceIncrement = newLocation.distance(from: lastLocation)
            distance += distanceIncrement / 1000 // Converter para quilômetros
        }

        lastLocation = newLocation

        // Update the map region on the main thread
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(
                center: newLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            self.routeCoordinates.append(newLocation.coordinate)
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }

    func resetData() {
        self.routeCoordinates = []
        self.distance = 0.0
        self.lastLocation = nil
    }
}
