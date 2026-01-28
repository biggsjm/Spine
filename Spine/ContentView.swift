import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    private var showOnboarding: Binding<Bool> {
        Binding(
            get: { !hasCompletedOnboarding },
            set: { if !$0 { hasCompletedOnboarding = true } }
        )
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            LogPainView()
                .tabItem {
                    Label("Log", systemImage: "square.and.pencil")
                }
                .tag(0)

            ExercisesView()
                .tabItem {
                    Label("Exercises", systemImage: "figure.walk")
                }
                .tag(1)

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(3)
        }
        .tint(.primary)
        .sheet(isPresented: showOnboarding) {
            OnboardingView()
        }
    }
}

#Preview {
    ContentView()
}
