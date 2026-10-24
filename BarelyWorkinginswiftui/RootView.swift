
import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showMain = false

    private let splashDuration: Double = 2.5

    var body: some View {
        Group {
            if !showMain {
                SplashView()
                    .transition(.opacity)
            } else if appState.isLoggedIn {
                TasksView()
                    .transition(.opacity)
            } else {
                AuthView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: showMain)
        .animation(.easeInOut(duration: 0.4), value: appState.isLoggedIn)
        .onAppear {
            guard !showMain else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + splashDuration) {
                withAnimation { showMain = true }
            }
        }
    }
}

#Preview {
    RootView()
}
