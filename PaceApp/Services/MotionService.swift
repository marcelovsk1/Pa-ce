import Foundation
import CoreMotion

class MotionService: ObservableObject {
    private var motionManager: CMMotionManager
    @Published var isMoving: Bool = false

    init() {  // Removed 'override' here
        motionManager = CMMotionManager()
        motionManager.accelerometerUpdateInterval = 0.1
        startUpdates()
    }

    private func startUpdates() {
        guard motionManager.isAccelerometerAvailable else { return }

        motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
            guard let data = data, error == nil else { return }
            self?.detectMovement(data: data)
        }
    }

    private func detectMovement(data: CMAccelerometerData) {
        let accelerationThreshold = 0.02 // Sensibilidade do movimento
        if abs(data.acceleration.x) > accelerationThreshold ||
           abs(data.acceleration.y) > accelerationThreshold ||
           abs(data.acceleration.z) > accelerationThreshold {
            isMoving = true
        } else {
            isMoving = false
        }
    }
}
