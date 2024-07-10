import SwiftUI

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
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Save state when app is about to become inactive
        UserDefaults.standard.synchronize()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Save state when app enters background
        UserDefaults.standard.synchronize()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Restore state when app enters foreground
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restore state when app becomes active
        NotificationCenter.default.post(name: Notification.Name("AppDidBecomeActive"), object: nil)
    }
}
