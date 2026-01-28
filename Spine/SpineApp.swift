import SwiftUI
import SwiftData

@main
struct SpineApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PainEntry.self,
            Exercise.self,
            ExerciseCompletion.self,
            Issue.self,
            Reminder.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // During development: delete corrupted store and retry
            let url = URL.applicationSupportDirectory.appending(path: "default.store")
            try? FileManager.default.removeItem(at: url)
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
