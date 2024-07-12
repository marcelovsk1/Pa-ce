import SwiftUI
import MapKit
import HealthKit

struct RunningView: View {
    @EnvironmentObject private var locationService: LocationService
    @AppStorage("distance") private var distance: Double = 0.0
    @AppStorage("duration") private var duration: TimeInterval = 0.0
    @AppStorage("pace") private var pace: Double = 0.0
    @State private var heartRate: Int?
    @AppStorage("elevation") private var elevation: Double = 0.0
    @AppStorage("isPaused") private var isPaused: Bool = false
    @AppStorage("isRunning") private var isRunning: Bool = false
    @State private var timer: Timer?
    @State private var temperature: String = "--"
    @AppStorage("heartRateAccessGranted") private var heartRateAccessGranted: Bool = false
    private let healthStore = HKHealthStore()
    @State private var currentHeartRateQuery: HKAnchoredObjectQuery?
    @EnvironmentObject var viewModel: RunViewModel
    @Binding var navigateToMainView: Bool

    var body: some View {
        ZStack {
            // Background Map
            RouteTrackingMapView(region: $locationService.region, routeCoordinates: $locationService.routeCoordinates, speeds: $locationService.speeds)
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    RadialGradient(gradient: Gradient(colors: [.white.opacity(1.0), .clear]), center: .top, startRadius: 200, endRadius: 500)
                        .edgesIgnoringSafeArea(.all)
                )
            
            // Overlay Content
            VStack {
                if isPaused {
                    PausedView(
                        distance: locationService.distance,
                        duration: duration,
                        pace: pace,
                        kcal: Int(locationService.distance * 60),
                        temperature: temperature,
                        elevation: elevation,
                        heartRate: heartRate,
                        onResume: resumeRun
                    )
                    .transition(.move(edge: .bottom))
                } else {
                    runningView
                        .transition(.move(edge: .bottom))
                }
            }

            // Heart Rate and Music Display
            if !isPaused {
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Button(action: {
                                connectToSpotify()
                            }) {
                                HStack {
                                    Image(systemName: "plus")
                                        .foregroundColor(.black)
                                        .font(.custom("Avenir Next", size: 18))
                                    Image(systemName: "music.note")
                                        .foregroundColor(.purple)
                                        .font(.custom("Avenir Next", size: 20))
                                        .bold()
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                            }
                        }
                        .padding()
                        Spacer()
                        VStack(alignment: .trailing) {
                            if heartRateAccessGranted {
                                if let heartRate = heartRate {
                                    HStack {
                                        Text("\(heartRate)")
                                            .font(.custom("Avenir Next", size: 20))
                                            .bold()
                                            .foregroundColor(.black)
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(.red)
                                            .font(.custom("Avenir Next", size: 20))
                                    }
                                } else {
                                    HStack {
                                        Text("--")
                                            .font(.custom("Avenir Next", size: 20))
                                            .bold()
                                            .foregroundColor(.black)
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(.red)
                                            .font(.custom("Avenir Next", size: 20))
                                    }
                                    .offset(y: -10)
                                }
                            } else {
                                Button(action: {
                                    requestHeartRateAccess()
                                }) {
                                    HStack {
                                        Image(systemName: "plus")
                                            .foregroundColor(.black)
                                            .font(.custom("Avenir Next", size: 18))
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(.red)
                                            .font(.custom("Avenir Next", size: 20))
                                            .bold()
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(Circle())
                                }
                            }
                        }
                        .padding()
                    }
                    Spacer()
                }
            }
        }
        .animation(.easeInOut, value: isPaused)
        .onAppear {
            if isRunning {
                isPaused = false // Ensure isPaused is false when starting the run
                startRun()
            } else {
                resetRunData()
                isRunning = true
                isPaused = false
                startRun()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            if isRunning && !isPaused {
                startRun()
            }
        }
    }
    
    var runningView: some View {
        VStack {
            Spacer().frame(height: 1) // Add a top spacing here
            
            HStack {
                Spacer()
                VStack {
                    HStack(alignment: .center) {
                        Text("\(String(format:"%.2f", locationService.distance))") // Use the distance from LocationService
                            .font(.custom("Avenir Next", size: 54))
                            .bold()
                            .offset(x: 1)
                            .foregroundColor(.black)
                    }
                    Text("Kilometers")
                        .font(.custom("Avenir Next", size: 18))
                }
                Spacer()
            }

            HStack {
                VStack {
                    Text(formattedTime(duration))
                        .font(.custom("Avenir Next", size: 26))
                        .bold()
                        .foregroundColor(.black)
                        .offset(x: -1)
                    Text("Time")
                        .font(.custom("Avenir Next", size: 14))
                        .foregroundColor(.black)
                        .offset(x: -1)
                }
                Spacer()
                VStack {
                    Text("\(Int(locationService.distance * 60))")
                        .font(.custom("Avenir Next", size: 26))
                        .bold()
                        .foregroundColor(.black)
                        .offset(x: -2)
                    Text("Kcal")
                        .font(.custom("Avenir Next", size: 14))
                        .foregroundColor(.black)
                        .offset(x: -1)
                }
                Spacer()
                VStack {
                    Text(formattedPace(pace))
                        .font(.custom("Avenir Next", size: 26))
                        .bold()
                        .foregroundColor(.black)
                        .offset(x: 1)
                    Text("Pace")
                        .font(.custom("Avenir Next", size: 14))
                        .foregroundColor(.black)
                        .offset(x: -2)

                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(5)
            .offset(y: -15)
            .padding([.leading, .trailing])
            .shadow(radius: 20)
            
            Spacer()
            
            HStack {
                Button(action: {
                    isPaused = true
                    isRunning = false
                    stopRun()
                    fetchTemperature()
                }) {
                    HStack {
                        Image(systemName: "stop")
                            .font(.title2)
                            .bold()
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .bold()
                    .padding()
                    .foregroundColor(.white)
                    .frame(width: 130, height: 130)
                    .background(Color(red: 0.1, green: 0.1, blue: 0.1))
                    .clipShape(Circle())
                    .padding()
                    .shadow(radius: 8)
                }
            }
            .padding(.bottom, 60)
            .navigationBarBackButtonHidden(true)
        }
    }

    func resetRunData() {
        distance = 0.0
        duration = 0.0
        pace = 0.0
        elevation = 0.0
        heartRate = nil
        temperature = "--"
        locationService.resetData()
    }

    func startRun() {
        isRunning = true
        isPaused = false
        locationService.startUpdatingLocation()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            duration += 1.0
            updatePace()
        }
        startHeartRateUpdates() // Adicione aqui para começar as atualizações da frequência cardíaca
    }

    func stopRun() {
        locationService.stopUpdatingLocation()
        timer?.invalidate()
        timer = nil
    }

    func resumeRun() {
        isPaused = false
        startRun()
    }

    func updatePace() {
        if locationService.distance > 0 {
            pace = duration / 60.0 / locationService.distance
        }
    }

    func fetchTemperature() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.temperature = "25" // Example temperature
        }
    }

    func requestHeartRateAccess() {
        let typesToShare: Set = [HKObjectType.workoutType()]
        let typesToRead: Set = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!
        ]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if success {
                DispatchQueue.main.async {
                    self.heartRateAccessGranted = true
                    self.startHeartRateUpdates()
                }
            } else {
                print("Heart rate access not granted.")
            }
        }
    }

    func startHeartRateUpdates() {
        guard heartRateAccessGranted else { return }

        // Start heart rate updates simulation
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            DispatchQueue.main.async {
                self.heartRate = Int.random(in: 60...140)
            }
        }
    }

    func stopHeartRateUpdates() {
        // No need to stop anything here as we are using a Timer directly in startHeartRateUpdates
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

    func connectToSpotify() {
        if let url = URL(string: "spotify://") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else if let webUrl = URL(string: "https://open.spotify.com") {
                UIApplication.shared.open(webUrl)
            }
        }
    }
}

#if DEBUG
struct RunningView_Previews: PreviewProvider {
    static var previews: some View {
        RunningView(navigateToMainView: .constant(false))
            .environmentObject(LocationService())
    }
}
#endif
