import SwiftUI
import SwiftData

struct LogPainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PainEntry.timestamp, order: .reverse) private var entries: [PainEntry]
    @FocusState private var isNotesFieldFocused: Bool

    @State private var painLevel: Double = 5
    @State private var selectedLocation = "L5"
    @State private var selectedSymptom = "Dull"
    @State private var selectedTrigger = "Unknown"
    @State private var notes = ""
    @State private var showingDetail = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Quick log section
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("PAIN LEVEL")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(Int(painLevel))")
                                .font(.system(.title, design: .monospaced, weight: .bold))
                                .foregroundStyle(painColor(for: Int(painLevel)))
                        }

                        Slider(value: $painLevel, in: 0...10, step: 1)
                            .tint(painColor(for: Int(painLevel)))
                    }

                    // Location, Symptom, Trigger
                    VStack(spacing: 12) {
                        PickerRow(title: "LOCATION", selection: $selectedLocation, options: PainEntry.locations)
                        PickerRow(title: "SYMPTOM", selection: $selectedSymptom, options: PainEntry.symptomTypes)
                        PickerRow(title: "TRIGGER", selection: $selectedTrigger, options: PainEntry.triggers)
                    }

                    // Optional notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("NOTES (OPTIONAL)")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.secondary)
                        TextField("Additional details...", text: $notes, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(2...4)
                            .focused($isNotesFieldFocused)
                    }

                    // Log button
                    Button(action: logPain) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Log Entry")
                                .font(.system(.body, design: .monospaced, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
                .background(Color(.systemBackground))

                Divider()

                // Recent entries header
                HStack {
                    Text("RECENT ENTRIES")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                    Spacer()
                    NavigationLink(destination: PainHistoryView()) {
                        Text("View All")
                            .font(.system(.caption, design: .monospaced))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 8)

                // Recent entries list (last 5)
                if entries.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("No entries yet")
                            .font(.system(.body, design: .default))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(entries.prefix(5)) { entry in
                            EntryRow(entry: entry)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                        .onDelete(perform: deleteEntries)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Log Pain")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isNotesFieldFocused = false
                    }
                }
            }
        }
    }

    private func logPain() {
        let entry = PainEntry(
            level: Int(painLevel),
            location: selectedLocation,
            symptomType: selectedSymptom,
            trigger: selectedTrigger,
            notes: notes.isEmpty ? nil : notes
        )
        modelContext.insert(entry)
        notes = ""

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(entries[index])
        }
    }

    private func painColor(for level: Int) -> Color {
        switch level {
        case 0...2: return .green
        case 3...4: return .yellow
        case 5...6: return .orange
        case 7...8: return .red
        default: return .purple
        }
    }
}

struct PickerRow: View {
    let title: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)

            Picker(title, selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(.menu)
            .tint(.primary)
        }
    }
}

struct EntryRow: View {
    let entry: PainEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.timestamp, style: .time)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(entry.level)")
                    .font(.system(.title3, design: .monospaced, weight: .bold))
                    .foregroundStyle(painColor(for: entry.level))
            }

            HStack(spacing: 12) {
                Label(entry.location, systemImage: "location.fill")
                Label(entry.symptomType, systemImage: "waveform.path.ecg")
                if let trigger = entry.trigger, trigger != "Unknown" {
                    Label(trigger, systemImage: "bolt.fill")
                }
            }
            .font(.system(.caption, design: .default))
            .foregroundStyle(.secondary)

            if let notes = entry.notes {
                Text(notes)
                    .font(.system(.caption, design: .default))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }

    private func painColor(for level: Int) -> Color {
        switch level {
        case 0...2: return .green
        case 3...4: return .yellow
        case 5...6: return .orange
        case 7...8: return .red
        default: return .purple
        }
    }
}

#Preview {
    LogPainView()
        .modelContainer(for: PainEntry.self, inMemory: true)
}
