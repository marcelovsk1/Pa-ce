// In CoreMotion.swift
import Foundation
import CoreMotion

class ActivityMotionService: ObservableObject {
    private let motionManager = CMMotionActivityManager()
    @Published var isMoving = false

    init() {
        startMotionUpdates()
    }

    func startMotionUpdates() {
        guard CMMotionActivityManager.isActivityAvailable() else { return }

        motionManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let activity = activity else { return }
            DispatchQueue.main.async {
                self?.isMoving = activity.walking || activity.running
            }
        }
    }

    func stopMotionUpdates() {
        motionManager.stopActivityUpdates()
    }
}
