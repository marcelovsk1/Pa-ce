import Foundation

struct Marathon: Identifiable {
    let id = UUID()
    let name: String
    let date: Date
    let location: String
}

class MarathonViewModel: ObservableObject {
    @Published var upcomingMarathons: [Marathon] = []

    private let dateFormatter: DateFormatter

    init() {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd"
        loadMarathons()
    }

    private func loadMarathons() {
        let marathons = [
            Marathon(name: "San Francisco Marathon", date: dateFormatter.date(from: "2024-07-28")!, location: "San Francisco, CA, USA"),
            Marathon(name: "Berlin Marathon", date: dateFormatter.date(from: "2024-09-29")!, location: "Berlin, Germany"),
            Marathon(name: "Chicago Marathon", date: dateFormatter.date(from: "2024-10-13")!, location: "Chicago, IL, USA"),
            Marathon(name: "New York City Marathon", date: dateFormatter.date(from: "2024-11-03")!, location: "New York, NY, USA"),
            Marathon(name: "Tokyo Marathon", date: dateFormatter.date(from: "2025-03-03")!, location: "Tokyo, Japan"),
            Marathon(name: "Boston Marathon", date: dateFormatter.date(from: "2025-04-15")!, location: "Boston, MA, USA"),
            Marathon(name: "London Marathon", date: dateFormatter.date(from: "2025-04-21")!, location: "London, UK")
        ].sorted { $0.date < $1.date }

        self.upcomingMarathons = marathons
    }

    func formatDate(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
}
