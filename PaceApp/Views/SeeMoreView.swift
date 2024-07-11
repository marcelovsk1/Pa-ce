import SwiftUI
import Charts

struct Activity: Identifiable {
    var id = UUID()
    var date: Date
    var distance: Double
    var duration: Double
}

struct SeeMoreView: View {
    @State private var selectedOption = 0

    let activities: [Activity] = [
        Activity(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, distance: 5.0, duration: 30.0),
        Activity(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, distance: 7.0, duration: 40.0),
        Activity(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, distance: 3.5, duration: 20.0),
        Activity(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, distance: 10.0, duration: 60.0),
        Activity(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, distance: 6.0, duration: 35.0),
        Activity(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, distance: 8.0, duration: 45.0),
        Activity(date: Date(), distance: 4.0, duration: 25.0)
    ]

    let weeklyActivities: [Activity] = (1...4).map { week in
        Activity(date: Calendar.current.date(byAdding: .weekOfYear, value: -week, to: Date())!, distance: Double.random(in: 15...25), duration: Double.random(in: 120...300))
    }

    let nineWeekActivities: [Activity] = (1...9).map { week in
        Activity(date: Calendar.current.date(byAdding: .weekOfYear, value: -week, to: Date())!, distance: Double.random(in: 20...50), duration: Double.random(in: 120...300))
    }

    func gradient(for distance: Double) -> LinearGradient {
        if distance < 5 {
            return LinearGradient(
                gradient: Gradient(colors: [.red]),
                startPoint: .bottom,
                endPoint: .top
            )
        } else if distance == 5 {
            return LinearGradient(
                gradient: Gradient(colors: [.red, .yellow]),
                startPoint: .bottom,
                endPoint: .top
            )
        } else {
            return LinearGradient(
                gradient: Gradient(colors: [.red, .yellow, .green]),
                startPoint: .bottom,
                endPoint: .top
            )
        }
    }

    func gradientForWeekly(distance: Double) -> LinearGradient {
        if distance < 20 {
            return LinearGradient(
                gradient: Gradient(colors: [.red]),
                startPoint: .bottom,
                endPoint: .top
            )
        } else if distance == 20 {
            return LinearGradient(
                gradient: Gradient(colors: [.red, .yellow]),
                startPoint: .bottom,
                endPoint: .top
            )
        } else {
            return LinearGradient(
                gradient: Gradient(colors: [.red, .yellow, .green]),
                startPoint: .bottom,
                endPoint: .top
            )
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How are you doing so far")
                .font(.custom("Avenir Next", size: 24))
                .offset(x: -45)
        }

        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 16) {
                        TabView(selection: $selectedOption) {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Weekly Distance")
                                    .font(.custom("Avenir Next", size: 18))

                                Chart {
                                    ForEach(activities) { activity in
                                        BarMark(
                                            x: .value("Date", activity.date, unit: .day),
                                            y: .value("Distance", activity.distance)
                                        )
                                        .foregroundStyle(gradient(for: activity.distance))
                                        .shadow(radius: 0.5)
                                    }
                                }
                                .chartXAxis {
                                    AxisMarks(values: .stride(by: .day)) { value in
                                        AxisValueLabel(format: .dateTime.weekday(), centered: true)
                                    }
                                }
                                .frame(height: 200)
                            }
                            .padding(.horizontal)
                            .tag(0)

                            VStack(alignment: .leading, spacing: 16) {
                                Text("Monthly Distance")
                                    .font(.custom("Avenir Next", size: 22))

                                Chart {
                                    ForEach(weeklyActivities.indices, id: \.self) { index in
                                        BarMark(
                                            x: .value("Week", "Week \(index + 1)"),
                                            y: .value("Distance", weeklyActivities[index].distance)
                                        )
                                        .foregroundStyle(gradientForWeekly(distance: weeklyActivities[index].distance))
                                    }
                                }
                                .chartXAxis {
                                    AxisMarks { value in
                                        AxisValueLabel(centered: true)
                                    }
                                }
                                .frame(height: 200)
                            }
                            .padding(.horizontal)
                            .tag(1)

                            VStack(alignment: .leading, spacing: 16) {
                                Text("Last 9 Weeks Distance")
                                    .font(.custom("Avenir Next", size: 22))

                                Chart {
                                    ForEach(nineWeekActivities.indices, id: \.self) { index in
                                        BarMark(
                                            x: .value("Week", "\(index + 1)W"),
                                            y: .value("Distance", nineWeekActivities[index].distance)
                                        )
                                        .foregroundStyle(gradient(for: nineWeekActivities[index].distance))
                                    }
                                }
                                .chartXAxis {
                                    AxisMarks { value in
                                        AxisValueLabel(centered: true)
                                    }
                                }
                                .frame(height: 200)
                            }
                            .padding(.horizontal)
                            .tag(2)
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(height: 250)
                    }

                    Picker("Options", selection: $selectedOption) {
                        Text("7 days").tag(0)
                        Text("4 weeks").tag(1)
                        Text("9 weeks").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

//                    VStack(alignment: .leading, spacing: 16) {
//                        Text("Weekly Duration")
//                            .font(.custom("Avenir Next", size: 22))
//
//                        Chart {
//                            ForEach(activities) { activity in
//                                LineMark(
//                                    x: .value("Date", activity.date, unit: .day),
//                                    y: .value("Duration", activity.duration)
//                                )
//                                .foregroundStyle(
//                                    LinearGradient(
//                                        gradient: Gradient(colors: [.red, .yellow, .green]),
//                                        startPoint: .bottom,
//                                        endPoint: .top
//                                    )
//                                )
//                                .symbol(.circle)
//                            }
//                        }
//                        .chartXAxis {
//                            AxisMarks(values: .stride(by: .day)) { value in
//                                AxisValueLabel(format: .dateTime.weekday(), centered: true)
//                            }
//                        }
//                        .frame(height: 200)
//                    }
//                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    SeeMoreView()
}
