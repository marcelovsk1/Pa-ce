import SwiftUI
import CoreLocation
import HealthKit

@main
struct ProjectRunningApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(LocationService())
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        CLLocationManager().requestAlwaysAuthorization()
        requestHealthAuthorization()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        UserDefaults.standard.synchronize()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        UserDefaults.standard.synchronize()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: Notification.Name("AppDidBecomeActive"), object: nil)
    }
    
    // HealthKit Authorization
    func requestHealthAuthorization() {
        let healthStore = HKHealthStore()
        
        if HKHealthStore.isHealthDataAvailable() {
            let writeDataTypes: Set = [
                HKObjectType.workoutType()
            ]
            
            let readDataTypes: Set = [
                HKObjectType.quantityType(forIdentifier: .heartRate)!
            ]
            
            healthStore.requestAuthorization(toShare: writeDataTypes, read: readDataTypes) { (success, error) in
                if !success {
                    // Handle the error here.
                    print("HealthKit authorization failed.")
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}
