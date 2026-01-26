import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

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

            AnalyticsView()
                .tabItem {
                    Label("Trends", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)

            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(3)

            RemindersView()
                .tabItem {
                    Label("Reminders", systemImage: "bell")
                }
                .tag(4)

            IssuesView()
                .tabItem {
                    Label("Issues", systemImage: "ladybug")
                }
                .tag(5)
        }
        .tint(.primary)
        .sheet(isPresented: $showOnboarding) {
            OnboardingView()
        }
    }
}

#Preview {
    ContentView()
}
