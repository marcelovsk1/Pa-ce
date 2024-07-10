import SwiftUI
import MapKit

struct UserTrackingMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        view.setRegion(region, animated: true)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: UserTrackingMapView

        init(_ parent: UserTrackingMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
            print("Failed to locate user: \(error.localizedDescription)")
        }
    }
}
