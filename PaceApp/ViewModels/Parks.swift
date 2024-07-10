//
//  Parcs.swift
//  ProjectRunning
//
//  Created by Marcelo Amaral Alves on 2024-06-29.
//

import MapKit

class ParkService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var parks: [MKMapItem] = []
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            fetchNearbyParks(location: location)
        }
    }

    func fetchNearbyParks(location: CLLocation) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Park"
        request.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let response = response {
                self.parks = response.mapItems
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error)")
    }
}
