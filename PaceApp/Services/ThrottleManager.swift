import Foundation

class ThrottleManager {
    private var requestCount = 0
    private var resetTime: Date?

    // Maximum requests allowed in the time window
    private let maxRequests = 50
    // Time window in seconds (60 seconds)
    private let windowSize: TimeInterval = 60

    // Method to check if a request can be made
    func canMakeRequest() -> Bool {
        let now = Date()

        // Reset the count if the window has passed
        if let resetTime = resetTime, now > resetTime {
            requestCount = 0
            self.resetTime = nil
        }

        if requestCount < maxRequests {
            requestCount += 1
            return true
        } else {
            if resetTime == nil {
                resetTime = now.addingTimeInterval(windowSize)
            }
            return false
        }
    }

    // Method to wait until requests can be made again
    func waitUntilReset(completion: @escaping () -> Void) {
        guard let resetTime = resetTime else {
            completion()
            return
        }

        let now = Date()
        let delay = resetTime.timeIntervalSince(now)

        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
            completion()
        }
    }
}
