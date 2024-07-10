import SwiftUI
import MapKit

struct RouteTrackingMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var routeCoordinates: [CLLocationCoordinate2D]
    @Binding var speeds: [CLLocationSpeed]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
        uiView.removeOverlays(uiView.overlays)
        if routeCoordinates.count > 1 {
            for i in 0..<routeCoordinates.count - 1 {
                let coords = [routeCoordinates[i], routeCoordinates[i + 1]]
                let polyline = ColorPolyline(coordinates: coords, count: coords.count)
                polyline.color = color(for: speeds[i])
                uiView.addOverlay(polyline)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func color(for speed: CLLocationSpeed) -> UIColor {
        switch speed {
        case ..<1.5: return .red
        case 1.5..<3.5: return .yellow
        case 3.5...: return .green
        default: return .blue
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: RouteTrackingMapView

        init(_ parent: RouteTrackingMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? ColorPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = polyline.color
                renderer.lineWidth = 9.0
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}

class ColorPolyline: MKPolyline {
    var color: UIColor = .blue
}
