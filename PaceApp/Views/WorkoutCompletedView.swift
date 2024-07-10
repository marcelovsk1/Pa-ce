import SwiftUI
import MapKit

struct WorkoutCompletedView: View {
    var distance: Double
    var duration: TimeInterval
    var pace: Double
    var kcal: Int
    var elevation: Double
    var heartRate: Int?
    @State private var runName: String = WorkoutCompletedView.defaultRunName()
    @State private var temperature: String = "--"
    @State private var weatherIcon: String = "sun.max" // Default weather icon

    // Sample coordinates representing the user's running path
    var coordinates: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 40.7580, longitude: -73.9855),
        CLLocationCoordinate2D(latitude: 40.7585, longitude: -73.9850),
        CLLocationCoordinate2D(latitude: 40.7590, longitude: -73.9845),
        // Add more coordinates as needed
    ]

    @EnvironmentObject var viewModel: RunViewModel

    static func defaultRunName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let dayOfWeek = formatter.string(from: Date())

        let hour = Calendar.current.component(.hour, from: Date())
        let timeOfDay: String
        switch hour {
        case 5..<12:
            timeOfDay = "Morning"
        case 12..<17:
            timeOfDay = "Afternoon"
        default:
            timeOfDay = "Evening"
        }

        return "\(dayOfWeek) \(timeOfDay) Run"
    }

    var body: some View {
        NavigationView {
            VStack {
                Spacer().frame(height: 0) // Add space for Dynamic Island

                // Mini map showing the running path
                WorkoutMapView(coordinates: coordinates)
                    .frame(height: 300)
                    .frame(width: 400)
                    .padding(.horizontal)
                    .shadow(radius: 5)
                    .edgesIgnoringSafeArea(.top) // Faz o mapa encostar na parte superior da tela

                HStack {
                    Text("\(String(format: "%.2f", distance))")
                        .font(.custom("Avenir Next", size: 60))
                        .bold()
                        .foregroundColor(Color.green)
                    +
                    Text(" Kilometers")
                        .font(.custom("Avenir Next", size: 20))
                        .foregroundColor(Color.green)
                }
                .offset(x: -40)
                .offset(y: -20)
                
                // Placeholder for run name
                HStack {
                    TextField("Enter run name", text: $runName)
                        .font(.custom("Avenir Next", size: 18))
                        .bold()
                        .padding(.vertical, 10)
                        .background(
                            VStack {
                                Spacer()
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.black)
                            }
                        )
                    Image(systemName: "pencil")
                        .foregroundColor(.gray)
                        .bold()
                }
                .padding(.horizontal)
                .padding(.top, -70)
                .offset(x: 10)

                Grid {
                    GridRow {
                        VStack {
                            Text(formattedTime(duration))
                                .font(.custom("Avenir Next", size: 24))
                                .bold()
                                .foregroundColor(Color.black)
                            Text("Time")
                                .font(.custom("Avenir Next", size: 18))
                                .foregroundColor(Color.black)
                        }
                        .gridCellColumns(1)

                        VStack {
                            Text(formattedPace(pace))
                                .font(.custom("Avenir Next", size: 24))
                                .bold()
                                .foregroundColor(Color.black)
                            Text("Pace")
                                .font(.custom("Avenir Next", size: 18))
                                .foregroundColor(Color.black)
                        }
                        .gridCellColumns(1)
                        
                        VStack {
                            Text("\(kcal)")
                                .font(.custom("Avenir Next", size: 24))
                                .bold()
                                .foregroundColor(Color.black)
                            Text("Kcal")
                                .font(.custom("Avenir Next", size: 18))
                                .foregroundColor(Color.black)
                        }
                        .gridCellColumns(1)

                    }

                    Divider()

                    GridRow {
                        VStack {
                            HStack {
                                Text("\(temperature)°")
                                    .font(.custom("Avenir Next", size: 24))
                                    .bold()
                                    .foregroundColor(Color.black)
                                Image(systemName: weatherIcon)
                                    .font(.custom("Avenir Next", size: 20))
                                    .bold()
                                    .foregroundColor(Color.black)
                            }
                            Text("Weather")
                                .font(.custom("Avenir Next", size: 18))
                                .foregroundColor(Color.black)
                        }
                        .gridCellColumns(1)
                        
   
                        
                        VStack {
                            Text(String(format: "%.2f", elevation) + " m")
                                .font(.custom("Avenir Next", size: 24))
                                .bold()
                                .foregroundColor(Color.black)
                            Text("Elevation")
                                .font(.custom("Avenir Next", size: 18))
                                .foregroundColor(Color.black)
                        }
                        .gridCellColumns(1)
                        
                        VStack {
                            Text(heartRate != nil ? "\(heartRate!)" : "--")
                                .font(.custom("Avenir Next", size: 24))
                                .bold()
                                .foregroundColor(Color.black)
                            Text("BPM")
                                .font(.custom("Avenir Next", size: 18))
                                .foregroundColor(Color.black)
                        }
                        .gridCellColumns(1)
                    }
                }
                .padding(10)
                .cornerRadius(10)
                .padding(.horizontal, 5)
                .offset(y: -15)

                Spacer()

                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title2)
                        .bold()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .foregroundColor(Color.white)
                        .frame(width: 130, height: 130)
                        .background(Color.black)
                        .clipShape(Circle())
                        .padding()
                        .shadow(radius: 5)
                        .onLongPressGesture(minimumDuration: 3) {
                            // Handle long press action here
                        }

                    Button(action: {
                        if let window = UIApplication.shared.windows.first {
                            window.rootViewController = UIHostingController(rootView: MainView()
                                .environmentObject(LocationService())
                                .environmentObject(RunViewModel())
                                .environmentObject(ParkService())
                                .environmentObject(MarathonViewModel()))
                            window.makeKeyAndVisible()
                        }
                    }) {
                        Image(systemName: "house")
                            .font(.title2)
                            .bold()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .frame(width: 130, height: 130)
                            .background(Color.purple)
                            .clipShape(Circle())
                            .padding()
                            .shadow(radius: 5)
                    }
                }
                .padding(.bottom, 50)
            }
            .padding()
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
            .onAppear {
                fetchWeather()
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func formattedPace(_ pace: Double) -> String {
        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)
        return String(format: "%d'%02d\"", minutes, seconds)
    }

    func fetchWeather() {
        // Replace this with actual weather fetching logic
        // For now, we will just simulate fetching weather data
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Simulate different weather conditions
            let weatherConditions = ["sun.max", "cloud.sun", "cloud", "cloud.rain"]
            let randomCondition = weatherConditions.randomElement() ?? "sun.max"

            self.weatherIcon = randomCondition
            self.temperature = "\(Int.random(in: 15...30))"
        }
    }
}

struct WorkoutMapView: UIViewRepresentable {
    var coordinates: [CLLocationCoordinate2D]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)
        mapView.delegate = context.coordinator

        // Zoom to fit the polyline
        let region = MKCoordinateRegion(polyline.boundingMapRect)
        mapView.setRegion(region, animated: false)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: WorkoutMapView

        init(_ parent: WorkoutMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 4.0
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}

#Preview {
    WorkoutCompletedView(distance: 5.0, duration: 3600, pace: 5.0, kcal: 200, elevation: 100.0, heartRate: 75)
}
