import SwiftUI
import MapKit
import CoreLocation

struct MainView: View {
    @StateObject private var locationService = LocationService()
    @StateObject private var viewModel = RunViewModel()
    @StateObject private var parkService = ParkService()
    @StateObject private var marathonViewModel = MarathonViewModel()
    @State private var isRunning = false
    @State private var mapOffset: CGFloat = 50
    @State private var navigateToMainView = false
    @State private var currentPage = 0
    @State private var isScrollingDisabled = false // Estado para desabilitar o scroll
    @State private var selectedTab = 1 // Estado para controlar a aba selecionada

    // Exemplo de dados simulados
    let numberOfActivities = 10
    let numberOfHours = 5
    let distanceInKm = 15.5

    func formattedTime(hours: Int) -> String {
        let h = hours
        let m = (hours * 60) % 60
        return "\(h)h\(String(format: "%02d", m))"
    }

    func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Criação de um efeito de desfoque com fundo branco translúcido
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        blurEffectView.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 49))
        
        UIGraphicsBeginImageContext(blurEffectView.frame.size)
        blurEffectView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        appearance.backgroundImage = image
        appearance.shadowImage = UIImage() // Remove a linha cinza
        appearance.shadowColor = .clear // Remove a sombra

        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black.withAlphaComponent(0.25)
        shadow.shadowOffset = CGSize(width: 0, height: 3)
        shadow.shadowBlurRadius = 110

        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.gray,
            .shadow: shadow
        ]
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.purple
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.purple,
            .shadow: shadow
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.purple
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: {
                        // Ação do botão
                    }) {
                        Text("MA")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(width: 35, height: 35)
                            .background(Color.gray)
                            .clipShape(Circle())
                            .shadow(radius: 1)
                            .offset(y: 20)
                            .offset(x: 5)
                    }
                    .padding(.leading)
                    
                    Spacer()
                    Image("Pace_Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 100)
                        .padding(.top, 10)
                        .offset(y: 15)
                        .offset(x: -25)
                        .shadow(radius: 0)
                    Spacer()
                }
                .background(Color.white)
                .shadow(radius: 1)
                
                TabView(selection: $selectedTab) {
                    NavigationView {
                        MapView(region: $locationService.region)
                    }
                    .tabItem {
                        Image(systemName: "map")
                        Text("Map")
                    }
                    .tag(0)

                    ZStack {
                        UserTrackingMapView(region: $locationService.region)
                            .frame(maxWidth: .infinity, maxHeight: 550)
                            .offset(y: mapOffset)
                            .offset(y: 20)
                            .overlay(
                                RadialGradient(gradient: Gradient(colors: [.clear, .white.opacity(2.9)]), center: .center, startRadius: 50, endRadius: 550)
                                    .offset(y: 50)
                                    .frame(maxWidth: .infinity, maxHeight: 550)
                                    .edgesIgnoringSafeArea(.top)
                                    .offset(y: 20)
                            )
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if value.translation.height > 0 {
                                            mapOffset = value.translation.height + 50
                                        }
                                    }
                                    .onEnded { _ in
                                        mapOffset = 50
                                    }
                            )

                        VStack {
                            Spacer()

                            NavigationLink(destination: RunningView(navigateToMainView: $navigateToMainView).environmentObject(locationService), isActive: $isRunning) {
                                EmptyView()
                            }

                            Button(action: {
                                viewModel.resetRunData()
                                isRunning = true
                                locationService.startUpdatingLocation()
                            }) {
                                Image(systemName: "play")
                                    .font(.title2)
                                    .bold()
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .padding()
                                    .foregroundColor(.white)
                                    .frame(width: 130, height: 130)
                                    .background(Color.purple)
                                    .clipShape(Circle())
                                    .padding()
                                    .shadow(radius: 10)
                                    .offset(y: 10)
                            }
                        }
                        .padding(.bottom, 50)

                        VStack(spacing: 30) {
                            HStack {
                                Text("Your Weekly Activity")
                                    .font(.custom("Avenir Next", size: 26))
                                    .foregroundColor(.black)
                                    .offset(y: 15)
                                    .offset(x: 20)
                                Spacer()
                                Button(action: {
                                    // Ação do botão "See more"
                                }) {
                                    HStack {
                                        Text("See more")
                                            .font(.custom("Avenir Next", size: 20))
                                            .bold()
                                            .foregroundColor(.purple)
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.purple)
                                    }
                                    .offset(y: 15)
                                    .offset(x: -15)
                                }
                            }
                            .padding(.horizontal)

                            HStack {
                                Spacer()
                                VStack {
                                    Text("\(numberOfActivities)")
                                        .font(.custom("Avenir Next", size: 24))
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    Text("Activities")
                                        .font(.custom("Avenir Next", size: 14))
                                        .foregroundColor(.black)
                                }
                                Spacer()
                                VStack {
                                    Text(formattedTime(hours: numberOfHours))
                                        .font(.custom("Avenir Next", size: 24))
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    Text("Time")
                                        .font(.custom("Avenir Next", size: 14))
                                        .foregroundColor(.black)
                                }
                                Spacer()
                                VStack {
                                    Text("\(distanceInKm, specifier: "%.1f") Km")
                                        .font(.custom("Avenir Next", size: 24))
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    Text("Distance")
                                        .font(.custom("Avenir Next", size: 14))
                                        .foregroundColor(.black)
                                }
                                Spacer()
                            }
                            Spacer()
                        }

                        VStack {
                            GeometryReader { geometry in
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        HStack {
                                            Image("first_run")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .cornerRadius(10)
                                                .offset(x: 10)
                                                .gesture(
                                                    DragGesture()
                                                        .onChanged { _ in isScrollingDisabled = true }
                                                )

                                            VStack(spacing: 10) {
                                                Text("Your First Run")
                                                    .font(.custom("Avenir Next", size: 18))
                                                    .bold()
                                                    .foregroundColor(.black)
                                                    .padding(.top)
                                                    .offset(y: 10)
                                                
                                                Text("Tips and tricks for your first run.")
                                                    .font(.custom("Avenir Next", size: 14))
                                                    .foregroundColor(.gray)
                                                    .padding(.horizontal)
                                                    .offset(y: -15)
                                                    .frame(maxWidth: .infinity, maxHeight: 100)
                                            }
                                        }
                                        .background(Color(UIColor.systemBackground).opacity(0.95))
                                        .cornerRadius(12)
                                        .shadow(radius: 10)
                                        .frame(width: 350, height: 120)
                                        .padding()
                                        .onTapGesture {
                                            isScrollingDisabled = true
                                        }
                                        
                                        NavigationLink(destination: ShoeRecommendationView()) {
                                            HStack {
                                                Image("shoes")
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 100, height: 100)
                                                    .cornerRadius(10)
                                                    .offset(x: 10)
                                                    .gesture(
                                                        DragGesture()
                                                            .onChanged { _ in isScrollingDisabled = true }
                                                    )

                                                VStack(spacing: 10) {
                                                    Text("Running Shoes for you?")
                                                        .font(.custom("Avenir Next", size: 18))
                                                        .bold()
                                                        .foregroundColor(.black)
                                                        .padding(.top)
                                                        .offset(y: 10)
                                                    
                                                    Text("Find out which shoes are best for running.")
                                                        .font(.custom("Avenir Next", size: 14))
                                                        .foregroundColor(.gray)
                                                        .padding(.horizontal)
                                                        .offset(y: -15)
                                                        .frame(maxWidth: .infinity, maxHeight: 100)
                                                }
                                            }
                                            .background(Color(UIColor.systemBackground).opacity(0.95))
                                            .cornerRadius(12)
                                            .shadow(radius: 10)
                                            .frame(width: 350, height: 120)
                                            .padding()
                                            .onTapGesture {
                                                isScrollingDisabled = true
                                            }
                                        }

                                        NavigationLink(destination: BestParksView().environmentObject(parkService).environmentObject(locationService)) {
                                            HStack {
                                                Image("running_locations")
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 100, height: 100)
                                                    .cornerRadius(10)
                                                    .offset(x: 10)
                                                    .gesture(
                                                        DragGesture()
                                                            .onChanged { _ in isScrollingDisabled = true }
                                                    )

                                                VStack(spacing: 10) {
                                                    Text("Best Running Locations")
                                                        .font(.custom("Avenir Next", size: 18))
                                                        .bold()
                                                        .foregroundColor(.black)
                                                        .padding(.top)
                                                        .offset(y: 10)
                                                    
                                                    Text("Click here and discover the best locations to run.")
                                                        .font(.custom("Avenir Next", size: 14))
                                                        .foregroundColor(.gray)
                                                        .padding(.horizontal)
                                                        .offset(y: -15)
                                                        .frame(maxWidth: .infinity, maxHeight: 100)
                                                }
                                            }
                                            .background(Color(UIColor.systemBackground).opacity(0.95))
                                            .cornerRadius(12)
                                            .shadow(radius: 10)
                                            .frame(width: 350, height: 120)
                                            .padding()
                                            .onTapGesture {
                                                isScrollingDisabled = true
                                            }
                                        }
                                        
                                        HStack {
                                            Image("marathon2")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .cornerRadius(10)
                                                .offset(x: 10)
                                                .gesture(
                                                    DragGesture()
                                                        .onChanged { _ in isScrollingDisabled = true }
                                                )

                                            VStack(spacing: 10) {
                                                Text("Upcoming Marathons")
                                                    .font(.custom("Avenir Next", size: 18))
                                                    .bold()
                                                    .foregroundColor(.black)
                                                    .padding(.top)
                                                    .offset(x: 0)
                                                
                                                TabView {
                                                    ForEach(marathonViewModel.upcomingMarathons) { marathon in
                                                        VStack(alignment: .leading) {
                                                            Text(marathon.name)
                                                                .font(.custom("Avenir Next", size: 14))
                                                                .foregroundColor(.black)
                                                            Text("\(marathonViewModel.formatDate(marathon.date)) - \(marathon.location)")
                                                                .font(.custom("Avenir Next", size: 12))
                                                                .foregroundColor(.gray)
                                                        }
                                                        .padding()
                                                        .cornerRadius(8)
                                                        .padding(.horizontal)
                                                        .offset(y: -21)
                                                        .frame(maxWidth: .infinity, maxHeight: 150)
                                                    }
                                                }
                                                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                                                .frame(height: 70)
                                            }
                                        }
                                        .background(Color(UIColor.systemBackground))
                                        .cornerRadius(12)
                                        .shadow(radius: 10)
                                        .frame(width: 350, height: 200)
                                        .padding()
                                        .onTapGesture {
                                            isScrollingDisabled = true
                                        }
                                        
                                        // Adicionando o botão de música
                                        Button(action: {
                                            if let url = URL(string: "spotify://") {
                                                if UIApplication.shared.canOpenURL(url) {
                                                    UIApplication.shared.open(url)
                                                } else if let webUrl = URL(string: "https://open.spotify.com") {
                                                    UIApplication.shared.open(webUrl)
                                                }
                                            }
                                        }) {
                                            HStack {
                                                Image("musics")
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 100, height: 100)
                                                    .cornerRadius(10)
                                                    .offset(x: 10)
                                                    .gesture(
                                                        DragGesture()
                                                            .onChanged { _ in isScrollingDisabled = true }
                                                    )

                                                VStack(spacing: 10) {
                                                    Text("Boost Your Run with Music!")
                                                        .font(.custom("Avenir Next", size: 16))
                                                        .bold()
                                                        .foregroundColor(.black)
                                                        .padding(.top)
                                                        .offset(y: 10)
                                                    
                                                    Text("Click here to connect your favorite music!")
                                                        .font(.custom("Avenir Next", size: 14))
                                                        .foregroundColor(.gray)
                                                        .padding(.horizontal)
                                                        .offset(y: -15)
                                                        .frame(maxWidth: .infinity, maxHeight: 100)
                                                }
                                            }
                                            .background(Color(UIColor.systemBackground).opacity(0.95))
                                            .cornerRadius(12)
                                            .shadow(radius: 10)
                                            .frame(width: 350, height: 120)
                                            .padding()
                                        }
                                    }
                                    .gesture(
                                        DragGesture()
                                            .onChanged { _ in
                                                isScrollingDisabled = true
                                            }
                                    )
                                }
                            }
                            .offset(y: 60)
                            .offset(x: 5)
                        }
                    }
                    .tabItem {
                        Image(systemName: "flag.checkered")
                        Text("Run")
                    }
                    .tag(1)

                    NavigationView {
                        VStack {
                            Text("Activities")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding()
                            Spacer()
                        }
                        .navigationTitle("Activities")
                    }
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("Activities")
                    }
                    .tag(2)
                }
            }
            .onAppear {
                locationService.checkLocationAuthorization()
                setupTabBarAppearance()
                selectedTab = 1 // Define a aba "Run" como padrão
            }
            .navigationBarTitle("", displayMode: .inline)
            .background(RadialGradient(gradient: Gradient(colors: [.clear, Color(red: 1.0, green: 0.98, blue: 0.94)]), center: .center, startRadius: 0, endRadius: 1200))
            .opacity(0.9)
            .edgesIgnoringSafeArea(.all)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let locationService = LocationService()
        locationService.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        let weatherService = WeatherService()
        
        return MainView()
            .environmentObject(locationService)
            .environmentObject(RunViewModel())
            .environmentObject(weatherService)
            .environmentObject(ParkService())
            .environmentObject(MarathonViewModel())
    }
}
#endif
