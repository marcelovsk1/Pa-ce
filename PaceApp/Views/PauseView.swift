import SwiftUI
import MapKit
import UIKit // Importar o UIKit para feedback tátil

struct PausedView: View {
    var distance: Double
    var duration: TimeInterval
    var pace: Double
    var kcal: Int
    var temperature: String
    var elevation: Double
    var heartRate: Int?
    var onResume: () -> Void
    @EnvironmentObject var locationService: LocationService // Adicionado

    @State private var isMapExpanded = false
    @State private var selectedTab = 0
    @State private var isLongPressActive = false
    @State private var showWarning = true // Mudamos para true para mostrar o aviso de forma estática
    @State private var savedRegion: MKCoordinateRegion? // Salva o estado do zoom
    @State private var navigateToCompleted = false // Estado para navegação

    var body: some View {
        NavigationView {
            VStack {
                if isMapExpanded {
                    ZStack {
                        Map(coordinateRegion: $locationService.region, interactionModes: [.all], showsUserLocation: true)
                            .edgesIgnoringSafeArea(.all)
                            .animation(.easeInOut, value: isMapExpanded)

                        VStack {
                            Spacer()
                                .frame(height: 50) // Adiciona espaço acima do botão
                            HStack {
                                Spacer()
                                Button(action: {
                                    withAnimation {
                                        savedRegion = locationService.region // Salva o estado atual
                                        isMapExpanded.toggle()
                                    }
                                }) {
                                    Image(systemName: "arrow.down.right.and.arrow.up.left")
                                        .padding()
                                        .background(Color.white.opacity(0.9))
                                        .clipShape(Circle())
                                        .shadow(radius: 5)
                                }
                                .padding()
                            }
                            Spacer()
                        }
                    }
                } else {
                    VStack {
                        TabView(selection: $selectedTab) {
                            ZStack {
                                Map(coordinateRegion: $locationService.region, interactionModes: [], showsUserLocation: true)
                                    .frame(height: 300) // Ajuste a altura aqui
                                    .edgesIgnoringSafeArea(.top)
                                    .animation(.easeInOut, value: isMapExpanded)

                                VStack {
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            withAnimation {
                                                if let savedRegion = savedRegion {
                                                    locationService.region = savedRegion // Restaura o estado salvo
                                                }
                                                isMapExpanded.toggle()
                                            }
                                        }) {
                                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                                .padding()
                                                .background(Color.white.opacity(0.9))
                                                .clipShape(Circle())
                                                .shadow(radius: 5)
                                        }
                                        .padding()
                                    }
                                    Spacer()
                                }
                            }
                            .tag(0)

                            LineChartView(data: generateSampleData())
                                .frame(height: 220)
                                .frame(width: 350)
                                .cornerRadius(15)
                                .padding(.horizontal)
                                .tag(1)
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(height: 300) // Ajuste a altura aqui

                        // Custom page indicators
                        HStack {
                            Circle()
                                .fill(selectedTab == 0 ? Color.green : Color.gray)
                                .frame(width: 10, height: 10)
                            Circle()
                                .fill(selectedTab == 1 ? Color.green : Color.gray)
                                .frame(width: 10, height: 10)
                        }
                        .padding(.vertical, 10)
                    }

                    Divider()
                        .padding(.vertical, 10)

                    Grid {
                        GridRow {
                            VStack {
                                Text("\(String(format: "%.2f", distance))")
                                    .font(.custom("Avenir Next", size: 24))
                                    .bold()
                                    .foregroundColor(.black)
                                    .offset(y: -5)
                                Text("Kilometers")
                                    .font(.custom("Coolvetica", size: 16))
                                    .foregroundColor(.black)
                            }
                            .gridCellColumns(1)

                            VStack {
                                Text(formattedPace(pace))
                                    .font(.custom("Avenir Next", size: 24))
                                    .bold()
                                    .foregroundColor(.black)
                                    .offset(y: -5)
                                Text("Pace")
                                    .font(.custom("Coolvetica", size: 16))
                                    .foregroundColor(.black)
                                    .offset(x: -2)
                            }
                            .gridCellColumns(1)

                            VStack {
                                Text(formattedTime(duration))
                                    .font(.custom("Avenir Next", size: 24))
                                    .bold()
                                    .foregroundColor(.black)
                                    .offset(y: -5)
                                Text("Time")
                                    .font(.custom("Coolvetica", size: 16))
                                    .foregroundColor(.black)
                            }
                            .gridCellColumns(1)
                        }

                        Divider()

                        GridRow {
                            VStack {
                                Text("\(kcal)")
                                    .font(.custom("Avenir Next", size: 24))
                                    .bold()
                                    .foregroundColor(.black)
                                Text("Kcal")
                                    .font(.custom("Coolvetica", size: 16))
                                    .foregroundColor(.black)
                            }
                            .gridCellColumns(1)

                            VStack {
                                Text(String(format: "%.2f", elevation) + " m")
                                    .font(.custom("Avenir Next", size: 24))
                                    .bold()
                                    .foregroundColor(.black)
                                Text("Elevation")
                                    .font(.custom("Coolvetica", size: 16))
                                    .foregroundColor(.black)
                            }
                            .gridCellColumns(1)

                            VStack {
                                Text(heartRate != nil ? "\(heartRate!)" : "--")
                                    .font(.custom("Avenir Next", size: 24))
                                    .bold()
                                    .foregroundColor(.black)
                                Text("BPM")
                                    .font(.custom("Coolvetica", size: 16))
                                    .foregroundColor(.black)
                            }
                            .gridCellColumns(1)
                        }
                    }
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)

                    Spacer()
                        .padding([.leading, .trailing], 20)
                        .cornerRadius(15)
                        .shadow(radius: 1)

                    Button(action: {
                        connectToSpotify()
                    }) {
                        Text("Connect Music")
                            .font(.custom("Coolvetica", size: 20))
                            .foregroundColor(.white)
                            .padding(15)
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(15)
                            .padding(.horizontal)
                            .shadow(radius: 5)
                    }
                    .padding(.bottom, 50)
                    .offset(y: 20)

                    VStack {
                        if showWarning {
                            Text("Hold the flag for 3 seconds to finish the workout")
                                .font(.custom("Coolvetica", size: 16))
                                .foregroundColor(.gray)
                                .padding(.bottom, 10)
                                .background(Color.clear)
                                .offset(y: -10)
                        }

                        HStack {
                            NavigationLink(destination: WorkoutCompletedView(distance: distance, duration: duration, pace: pace, kcal: kcal, elevation: elevation, heartRate: heartRate)
                                            .environmentObject(locationService), isActive: $navigateToCompleted) {
                                EmptyView()
                            }

                            Image(systemName: "flag.checkered")
                                .font(.title2)
                                .bold()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .frame(width: 135, height: 135)
                                .background(Color.black)
                                .clipShape(Circle())
                                .padding()
                                .shadow(radius: 5)
                                .onLongPressGesture(minimumDuration: 3) {
                                    navigateToCompleted = true
                                    // Feedback tátil ao iniciar o gesto de pressionar longamente
                                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                                    generator.impactOccurred()
                                    // Reset data
                                    locationService.resetData()
                                }

                            Button(action: {
                                locationService.startUpdatingLocation()
                                onResume()
                            }) {
                                Image(systemName: "play")
                                    .font(.title2)
                                    .bold()
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .padding()
                                    .foregroundColor(.white)
                                    .frame(width: 135, height: 135)
                                    .background(Color.purple)
                                    .clipShape(Circle())
                                    .padding()
                                    .shadow(radius: 5)
                            }
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.top)
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

    func generateSampleData() -> [ChartData] {
        // Generate some sample data
        return (0..<10).map { i in
            ChartData(time: Double(i), elevation: Double(i * 10))
        }
    }

    func connectToSpotify() {
        if let url = URL(string: "spotify:") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                if let webURL = URL(string: "https://www.spotify.com") {
                    UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
                }
            }
        }
    }
}

#if DEBUG
struct PausedView_Previews: PreviewProvider {
    static var previews: some View {
        PausedView(distance: 5.0, duration: 3600, pace: 5.0, kcal: 200, temperature: "25", elevation: 100.0, heartRate: 75, onResume: {})
            .environmentObject(LocationService()) // Adicionado para pré-visualização
    }
}
#endif
