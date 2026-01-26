import SwiftUI
import UserNotifications

struct SettingsView: View {
    @State private var notificationsEnabled = false
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Image(systemName: notificationsEnabled ? "bell.badge.fill" : "bell.slash.fill")
                            .foregroundStyle(notificationsEnabled ? .blue : .orange)
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notifications")
                                .font(.system(.body, design: .default, weight: .medium))
                            Text(notificationStatusText)
                                .font(.system(.caption, design: .default))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if notificationsEnabled {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                    .padding(.vertical, 4)

                    if !notificationsEnabled {
                        Button(action: requestNotificationPermission) {
                            HStack {
                                Text("Enable Notifications")
                                Spacer()
                                Image(systemName: "arrow.right.circle")
                            }
                        }
                        .tint(.blue)
                    }

                    Button(action: openSettings) {
                        HStack {
                            Text("Open System Settings")
                            Spacer()
                            Image(systemName: "arrow.up.forward.app")
                        }
                    }
                    .tint(.secondary)
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Enable notifications to receive reminders for pain logging, exercises, and medication.")
                }

                Section {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Apple Health")
                                .font(.system(.body, design: .default, weight: .medium))
                            Text("Coming soon")
                                .font(.system(.caption, design: .default))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("Soon")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.tertiarySystemFill))
                            .clipShape(Capsule())
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Integrations")
                } footer: {
                    Text("Connect to Apple Health to sync your activity and health data.")
                }

                Section {
                    Button(action: showOnboarding) {
                        HStack {
                            Image(systemName: "book.pages")
                                .foregroundStyle(.blue)
                            Text("Show Welcome Guide")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(.primary)
                } header: {
                    Text("Help")
                }

                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (Beta)")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                checkNotificationPermission()
            }
        }
    }

    private var notificationStatusText: String {
        switch notificationStatus {
        case .authorized:
            return "Enabled"
        case .denied:
            return "Denied - tap to open Settings"
        case .provisional:
            return "Provisional"
        case .ephemeral:
            return "Ephemeral"
        case .notDetermined:
            return "Not set up"
        @unknown default:
            return "Unknown"
        }
    }

    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationStatus = settings.authorizationStatus
                notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                notificationsEnabled = granted
                checkNotificationPermission()
                if !granted {
                    openSettings()
                }
            }
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    private func showOnboarding() {
        hasCompletedOnboarding = false
    }
}

#Preview {
    SettingsView()
}
