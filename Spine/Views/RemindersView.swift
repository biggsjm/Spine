import SwiftUI
import SwiftData
import UserNotifications

struct RemindersView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var reminders: [Reminder]

    @State private var showingAddReminder = false
    @State private var notificationsEnabled = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !notificationsEnabled {
                    notificationBanner
                }

                if reminders.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(reminders) { reminder in
                            ReminderRow(reminder: reminder)
                                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                        }
                        .onDelete(perform: deleteReminders)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddReminder = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddReminder) {
                AddReminderView()
            }
            .onAppear {
                checkNotificationPermission()
            }
        }
    }

    private var notificationBanner: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "bell.slash.fill")
                    .foregroundStyle(.orange)
                Text("Notifications are disabled")
                    .font(.system(.body, design: .default, weight: .medium))
                Spacer()
            }
            Button("Enable in Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.system(.caption, design: .monospaced))
        }
        .padding()
        .background(Color(.secondarySystemBackground))
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.badge")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("No reminders set")
                .font(.system(.title3, design: .default, weight: .medium))
            Text("Add reminders to log pain, do exercises, or take medication")
                .font(.system(.body, design: .default))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showingAddReminder = true
            } label: {
                Text("Add Reminder")
                    .font(.system(.body, design: .monospaced, weight: .medium))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 8)
        }
        .padding()
        .frame(maxHeight: .infinity)
    }

    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }

    private func deleteReminders(at offsets: IndexSet) {
        for index in offsets {
            let reminder = reminders[index]
            // Cancel notification
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString])
            modelContext.delete(reminder)
        }
    }
}

struct ReminderRow: View {
    @Bindable var reminder: Reminder

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Toggle("", isOn: $reminder.isEnabled)
                .labelsHidden()
                .onChange(of: reminder.isEnabled) { _, newValue in
                    if newValue {
                        scheduleNotification(for: reminder)
                    } else {
                        cancelNotification(for: reminder)
                    }
                }

            VStack(alignment: .leading, spacing: 8) {
                Text(reminder.title)
                    .font(.system(.body, design: .default, weight: .medium))

                Text(reminder.reminderDescription)
                    .font(.system(.caption, design: .default))
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Label(reminder.time, style: .time)
                    Label(reminder.category, systemImage: categoryIcon(reminder.category))
                    if reminder.repeatDaily {
                        Label("Daily", systemImage: "repeat")
                    }
                }
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    private func categoryIcon(_ category: String) -> String {
        switch category.lowercased() {
        case "pain log": return "square.and.pencil"
        case "exercise": return "figure.walk"
        case "medication": return "pills"
        default: return "bell"
        }
    }

    private func scheduleNotification(for reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.reminderDescription
        content.sound = .default

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminder.time)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: reminder.repeatDaily)
        let request = UNNotificationRequest(identifier: reminder.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    private func cancelNotification(for reminder: Reminder) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString])
    }
}

struct AddReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @State private var description = ""
    @State private var time = Date()
    @State private var repeatDaily = true
    @State private var category = "Pain Log"

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section {
                    DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                    Toggle("Repeat Daily", isOn: $repeatDaily)
                    Picker("Category", selection: $category) {
                        ForEach(Reminder.categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                }
            }
            .navigationTitle("Add Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addReminder()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private func addReminder() {
        // Request notification permission if needed
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    let reminder = Reminder(
                        title: title,
                        reminderDescription: description,
                        time: time,
                        repeatDaily: repeatDaily,
                        category: category
                    )
                    modelContext.insert(reminder)

                    // Schedule notification
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = description.isEmpty ? "Time for your \(category.lowercased())" : description
                    content.sound = .default

                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.hour, .minute], from: time)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: repeatDaily)
                    let request = UNNotificationRequest(identifier: reminder.id.uuidString, content: content, trigger: trigger)

                    UNUserNotificationCenter.current().add(request)
                }
                dismiss()
            }
        }
    }
}

#Preview {
    RemindersView()
        .modelContainer(for: Reminder.self, inMemory: true)
}
