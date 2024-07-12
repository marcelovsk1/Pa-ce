import SwiftUI

struct CountdownView: View {
    @State private var counter = 3
    @State private var isActive = true
    @State private var rotateDegree: Double = 0
    @Binding var navigateToRunningView: Bool

    var body: some View {
        VStack {
            if isActive {
                ZStack {
                    Circle()
                        .stroke(Color.purple.opacity(0.3), lineWidth: 20)
                        .frame(width: 200, height: 200)
                        .scaleEffect(isActive ? 1.0 : 0.1)
                        .opacity(isActive ? 1.0 : 0.0)
                        .transition(.scale)

                    if counter > 0 {
                        Text("\(counter)")
                            .font(.custom("Avenir Next", size: 96))
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                            .scaleEffect(isActive ? 1.0 : 0.1)
                            .opacity(isActive ? 1.0 : 0.0)
                            .rotationEffect(.degrees(rotateDegree))
                            .transition(.scale)
                    } else {
                        Image(systemName: "flag.checkered.2.crossed")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 100)
                            .foregroundColor(.purple)
                            .rotationEffect(.degrees(rotateDegree))
                            .transition(.scale)
                            .animation(.easeInOut(duration: 1.0), value: rotateDegree)
                    }
                }
                .padding()
                .onAppear {
                    startCountdown()
                }
            } else {
                NavigationLink(destination: RunningView(navigateToMainView: $navigateToRunningView)
                                .navigationBarBackButtonHidden(true)
                                .navigationBarHidden(true), isActive: $navigateToRunningView) {
                    EmptyView()
                }
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }

    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            withAnimation(.easeInOut(duration: 1.0)) {
                if self.counter > 0 {
                    self.counter -= 1
                    self.rotateDegree += 360
                } else {
                    self.isActive = false
                    self.rotateDegree += 360
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.navigateToRunningView = true
                    }
                    timer.invalidate()
                }
            }
        }
    }
}

#if DEBUG
struct CountdownView_Previews: PreviewProvider {
    static var previews: some View {
        CountdownView(navigateToRunningView: .constant(false))
    }
}
#endif
