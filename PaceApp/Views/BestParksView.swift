import SwiftUI
import MapKit

struct BestParksView: View {
    @EnvironmentObject var parkService: ParkService
    @EnvironmentObject var locationService: LocationService
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var numPparksToShow: Int = 5
    @State private var parksToShow: [MKMapItem] = []

    var body: some View {
        ZStack {
            if parksToShow.isEmpty {
                Text("No parks available")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            } else {
                Map(coordinateRegion: $region, annotationItems: parksToShow.map { IdentifiablePark(mapItem: $0) }) { park in
                    MapAnnotation(coordinate: park.placemark.coordinate) {
                        VStack {
                            Text(park.name ?? "Unknown Park")
                                .font(.caption)
                                .padding(10)
                                .foregroundColor(.white)
                                .background(Color.purple)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                            Text("📍")
                                .foregroundColor(.red)
                                .font(.title)
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()
                    Rectangle()
//                        .fill(Color.white.opacity(0.8))
                        .frame(height: 250)
                        .frame(width: 400)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                        .overlay(
                            List(parksToShow, id: \.self) { park in
                                VStack(alignment: .leading) {
                                    Text(park.name ?? "Unknown Park")
                                        .font(.custom("Avenir Next", size: 20))
                                    Text(park.placemark.title ?? "")
                                        .font(.custom("Avenir Next", size: 16))
                                        .foregroundColor(.gray)
                                    Button(action: {
                                        openMaps(for: park)
                                    }) {
                                        Text("Get Directions")
                                            .font(.custom("Avenir Next", size: 16))
                                            .foregroundColor(.white)
                                            .padding(5)
                                            .background(Color.green)
                                            .cornerRadius(5)
                                            .shadow(radius: 0.5)
                                    }
                                }
                                .padding()
//                                .shadow(radius: 10)
                            }
                        )
//                        .padding(.bottom, 15) // Adicionado para evitar a sobreposição da barra cinza
                }
            }

            VStack {
                HStack {
                    Text("Best Running Locations")
                        .font(.custom("Avenir Next", size: 24))
                        .bold()
                        .padding()
                        .offset(x: 65)
                        .offset(y: 25)
                    Spacer()
                }
                .frame(height: 100) // Aumentar a altura da barra branca
                .background(Color.white)
                .shadow(radius: 0.1)
                
                Spacer()
            }
            .edgesIgnoringSafeArea(.top)
        }

        .onAppear {
            region = MKCoordinateRegion(
                center: locationService.region.center,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            updateParksToShow()
        }
    }

    private func updateParksToShow() {
        parksToShow = Array(parkService.parks.prefix(numPparksToShow))
    }

    private func openMaps(for park: MKMapItem) {
        let destinationCoordinate = park.placemark.coordinate
        let destinationName = park.name ?? "Park"
        let regionDistance: CLLocationDistance = 1000
        let coordinates = CLLocationCoordinate2DMake(destinationCoordinate.latitude, destinationCoordinate.longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        
        let placemark = MKPlacemark(coordinate: coordinates)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = destinationName
        mapItem.openInMaps(launchOptions: options)
    }
}


#if DEBUG
struct BestParksView_Previews: PreviewProvider {
    static var previews: some View {
        let parkService = ParkService()
        let locationService = LocationService()

        // Example data for preview
        parkService.parks = [
            MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), addressDictionary: ["Name": "Park 1"])),
            MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 37.7750, longitude: -122.4195), addressDictionary: ["Name": "Park 2"])),
            MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 37.7751, longitude: -122.4196), addressDictionary: ["Name": "Park 3"]))
            // Add more parks if needed for testing
        ]

        locationService.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )

        return BestParksView()
            .environmentObject(parkService)
            .environmentObject(locationService)
    }
}
#endif
