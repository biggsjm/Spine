import SwiftUI
import SwiftData

struct PainHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PainEntry.timestamp, order: .reverse) private var allEntries: [PainEntry]

    @State private var searchText = ""
    @State private var filterLocation = "All"
    @State private var filterTimeRange = "All Time"
    @State private var showingShareSheet = false
    @State private var exportText = ""

    let timeRanges = ["All Time", "Today", "This Week", "This Month"]

    var filteredEntries: [PainEntry] {
        var entries = allEntries

        // Location filter
        if filterLocation != "All" {
            entries = entries.filter { $0.location.contains(filterLocation) }
        }

        // Time range filter
        let calendar = Calendar.current
        let now = Date()
        switch filterTimeRange {
        case "Today":
            entries = entries.filter { calendar.isDateInToday($0.timestamp) }
        case "This Week":
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
            entries = entries.filter { $0.timestamp >= weekAgo }
        case "This Month":
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
            entries = entries.filter { $0.timestamp >= monthAgo }
        default:
            break
        }

        // Search filter
        if !searchText.isEmpty {
            entries = entries.filter { entry in
                entry.location.localizedCaseInsensitiveContains(searchText) ||
                entry.symptomType.localizedCaseInsensitiveContains(searchText) ||
                (entry.trigger?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (entry.notes?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        return entries
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filters
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Picker("Location", selection: $filterLocation) {
                            Text("All").tag("All")
                            ForEach(["L3", "L4", "L5", "S1"], id: \.self) { location in
                                Text(location).tag(location)
                            }
                        }
                        .pickerStyle(.menu)

                        Picker("Time", selection: $filterTimeRange) {
                            ForEach(timeRanges, id: \.self) { range in
                                Text(range).tag(range)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                .padding()

                if filteredEntries.isEmpty {
                    emptyState
                } else {
                    // Summary stats
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            StatBadge(title: "ENTRIES", value: "\(filteredEntries.count)")
                            StatBadge(title: "AVG PAIN", value: String(format: "%.1f", averagePain))
                            StatBadge(title: "HIGHEST", value: "\(highestPain)")
                            StatBadge(title: "LOWEST", value: "\(lowestPain)")
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 12)

                    Divider()

                    // Entries list
                    List {
                        ForEach(filteredEntries) { entry in
                            DetailedEntryRow(entry: entry)
                                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                        }
                        .onDelete(perform: deleteEntries)
                    }
                    .listStyle(.plain)
                    .searchable(text: $searchText, prompt: "Search entries...")
                }
            }
            .navigationTitle("Pain History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !filteredEntries.isEmpty {
                        Button {
                            exportPainData()
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: [exportText])
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("No entries found")
                .font(.system(.title3, design: .default, weight: .medium))
            Text("Try adjusting your filters")
                .font(.system(.body, design: .default))
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
    }

    private var averagePain: Double {
        guard !filteredEntries.isEmpty else { return 0 }
        let sum = filteredEntries.reduce(0) { $0 + $1.level }
        return Double(sum) / Double(filteredEntries.count)
    }

    private var highestPain: Int {
        filteredEntries.map { $0.level }.max() ?? 0
    }

    private var lowestPain: Int {
        filteredEntries.map { $0.level }.min() ?? 0
    }

    private func exportPainData() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        var text = "MyBackFit Pain History Export\n"
        text += "Generated: \(dateFormatter.string(from: Date()))\n"
        text += "Filter: \(filterLocation) - \(filterTimeRange)\n"
        text += "\n"
        text += "Summary Statistics:\n"
        text += "Total Entries: \(filteredEntries.count)\n"
        text += "Average Pain Level: \(String(format: "%.1f", averagePain))\n"
        text += "Highest Pain: \(highestPain)\n"
        text += "Lowest Pain: \(lowestPain)\n"
        text += "\n" + String(repeating: "=", count: 50) + "\n\n"

        for entry in filteredEntries {
            text += "\(dateFormatter.string(from: entry.timestamp))\n"
            text += "Pain Level: \(entry.level)/10\n"
            text += "Location: \(entry.location)\n"
            text += "Symptom: \(entry.symptomType)\n"
            if let trigger = entry.trigger {
                text += "Trigger: \(trigger)\n"
            }
            if let notes = entry.notes {
                text += "Notes: \(notes)\n"
            }
            text += "\n" + String(repeating: "-", count: 50) + "\n\n"
        }

        exportText = text
        showingShareSheet = true
    }

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredEntries[index])
        }
    }
}

struct StatBadge: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(.title3, design: .monospaced, weight: .bold))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct DetailedEntryRow: View {
    let entry: PainEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.timestamp, style: .date)
                        .font(.system(.body, design: .default, weight: .medium))
                    Text(entry.timestamp, style: .time)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("PAIN LEVEL")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.secondary)
                    Text("\(entry.level)")
                        .font(.system(.title2, design: .monospaced, weight: .bold))
                        .foregroundStyle(painColor(for: entry.level))
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                InfoRow(icon: "location.fill", label: "Location", value: entry.location)
                InfoRow(icon: "waveform.path.ecg", label: "Symptom", value: entry.symptomType)
                if let trigger = entry.trigger, trigger != "Unknown" {
                    InfoRow(icon: "bolt.fill", label: "Trigger", value: trigger)
                }
            }

            if let notes = entry.notes, !notes.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 4) {
                    Text("NOTES")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.secondary)
                    Text(notes)
                        .font(.system(.body, design: .default))
                }
            }
        }
        .padding(.vertical, 8)
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

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(.caption))
                .foregroundStyle(.blue)
                .frame(width: 20)
            Text(label)
                .font(.system(.caption, design: .default))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(.caption, design: .default, weight: .medium))
            Spacer()
        }
    }
}

#Preview {
    PainHistoryView()
        .modelContainer(for: PainEntry.self, inMemory: true)
}
