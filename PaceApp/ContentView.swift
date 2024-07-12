//import SwiftUI
//
//struct ContentView: View {
//    @Binding var lastSelectedTab: Int // Binding to keep track of the last selected tab
//
//    var body: some View {
//        MainView(selectedTab: $lastSelectedTab) // Pass the binding to the MainView
//    }
//}
//
//
//#Preview {
//    ContentView()
//}

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = YourServiceOrViewModel()

    var body: some View {
        VStack {
            Button("Make Request") {
                viewModel.performSearchRequest()
            }
        }
        .onAppear {
            viewModel.performSearchRequest()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
