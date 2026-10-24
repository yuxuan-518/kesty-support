//
//import SwiftUI
//
//@main
//struct BarelyWorkinginswiftuiApp: App {
//    @StateObject private var appState = AppState()
//
//    var body: some Scene {
//        WindowGroup {
//            RootView()
//                .environmentObject(appState)
//        }
//    }
//}


import SwiftUI

@main
struct BarelyWorkinginswiftuiApp: App {
    @StateObject private var appState = AppState()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                appState.checkDailyReset()
            }
        }
    }
}
