import SwiftUI
import Combine

class RunViewModel: ObservableObject {
    @Published var runs: [Run] = []
    @Published var isRunning: Bool = false
    @Published var distance: Double = 0.0
    @Published var duration: TimeInterval = 0.0
    @Published var pace: Double = 0.0
    @Published var elevation: Double = 0.0
    @Published var heartRate: Int? = nil
    @Published var isPaused: Bool = false
    @Published var temperature: String = "--"
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Initialize with some mock data or fetch from a service
    }
    
    func startRun() {
        isRunning = true
        isPaused = false
        // Logic to start a run
    }
    
    func pauseRun() {
        isPaused = true
        isRunning = false
        // Logic to pause a run
    }
    
    func resumeRun() {
        isPaused = false
        isRunning = true
        // Logic to resume a run
    }
    
    func endRun() {
        isRunning = false
        isPaused = false
        // Logic to end a run and save data
        saveRunData()
    }
    
    func resetRunData() {
        distance = 0.0
        duration = 0.0
        pace = 0.0
        elevation = 0.0
        heartRate = nil
        temperature = "--"
    }
    
    private func saveRunData() {
        // Logic to save run data
    }
}
