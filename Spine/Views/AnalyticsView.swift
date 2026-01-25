import SwiftUI
import SwiftData
import Charts

struct AnalyticsView: View {
    @Query(sort: \PainEntry.timestamp, order: .reverse) private var entries: [PainEntry]
    @Query(sort: \ExerciseCompletion.timestamp, order: .reverse) private var completions: [ExerciseCompletion]

    @State private var timeRange = TimeRange.week

    enum TimeRange: String, CaseIterable {
        case week = "7D"
        case twoWeeks = "14D"
        case month = "30D"

        var days: Int {
            switch self {
            case .week: return 7
            case .twoWeeks: return 14
            case .month: return 30
            }
        }
    }

    var filteredEntries: [PainEntry] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -timeRange.days, to: Date()) ?? Date()
        return entries.filter { $0.timestamp >= cutoff }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Time range picker
                    Picker("Range", selection: $timeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    if filteredEntries.isEmpty {
                        emptyState
                    } else {
                        // Stats cards
                        statsSection

                        // Pain trend chart
                        painChartSection

                        // Symptom breakdown
                        symptomBreakdownSection

                        // Trigger analysis
                        triggerAnalysisSection

                        // Exercise compliance
                        exerciseComplianceSection
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Trends")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("No data yet")
                .font(.system(.title3, design: .default, weight: .medium))
            Text("Start logging pain to see trends")
                .font(.system(.body, design: .default))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "AVG PAIN",
                value: String(format: "%.1f", averagePain),
                color: painColor(for: Int(averagePain))
            )
            StatCard(
                title: "ENTRIES",
                value: "\(filteredEntries.count)",
                color: .blue
            )
            StatCard(
                title: "GOOD DAYS",
                value: "\(goodDays)",
                color: .green
            )
        }
        .padding(.horizontal)
    }

    private var painChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PAIN TREND")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Chart {
                ForEach(dailyAverages, id: \.date) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Pain", item.average)
                    )
                    .foregroundStyle(.blue)

                    PointMark(
                        x: .value("Date", item.date),
                        y: .value("Pain", item.average)
                    )
                    .foregroundStyle(.blue)
                }
            }
            .chartYScale(domain: 0...10)
            .chartYAxis {
                AxisMarks(position: .leading, values: [0, 5, 10])
            }
            .frame(height: 200)
            .padding(.horizontal)
        }
    }

    private var symptomBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SYMPTOMS")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            VStack(spacing: 8) {
                ForEach(symptomCounts.sorted(by: { $0.value > $1.value }), id: \.key) { symptom, count in
                    HStack {
                        Text(symptom)
                            .font(.system(.body, design: .default))
                        Spacer()
                        Text("\(count)")
                            .font(.system(.body, design: .monospaced, weight: .medium))
                            .foregroundStyle(.secondary)
                        Rectangle()
                            .fill(.blue.opacity(0.3))
                            .frame(width: CGFloat(count) / CGFloat(filteredEntries.count) * 100, height: 8)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    private var triggerAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TRIGGERS")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            VStack(spacing: 8) {
                ForEach(triggerCounts.sorted(by: { $0.value > $1.value }), id: \.key) { trigger, count in
                    HStack {
                        Text(trigger)
                            .font(.system(.body, design: .default))
                        Spacer()
                        Text("\(count)")
                            .font(.system(.body, design: .monospaced, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    private var exerciseComplianceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("EXERCISE COMPLIANCE")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            if completions.isEmpty {
                Text("No exercises logged yet")
                    .font(.system(.body, design: .default))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                VStack(spacing: 8) {
                    HStack {
                        Text("Sessions")
                        Spacer()
                        Text("\(recentCompletions)")
                            .font(.system(.body, design: .monospaced, weight: .medium))
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var averagePain: Double {
        guard !filteredEntries.isEmpty else { return 0 }
        let sum = filteredEntries.reduce(0) { $0 + $1.level }
        return Double(sum) / Double(filteredEntries.count)
    }

    private var goodDays: Int {
        let calendar = Calendar.current
        var daysWithLowPain = Set<Date>()

        for entry in filteredEntries where entry.level <= 3 {
            let day = calendar.startOfDay(for: entry.timestamp)
            daysWithLowPain.insert(day)
        }

        return daysWithLowPain.count
    }

    private var dailyAverages: [(date: Date, average: Double)] {
        let calendar = Calendar.current
        var dailyData: [Date: [Int]] = [:]

        for entry in filteredEntries {
            let day = calendar.startOfDay(for: entry.timestamp)
            dailyData[day, default: []].append(entry.level)
        }

        return dailyData.map { date, levels in
            let avg = Double(levels.reduce(0, +)) / Double(levels.count)
            return (date: date, average: avg)
        }.sorted { $0.date < $1.date }
    }

    private var symptomCounts: [String: Int] {
        var counts: [String: Int] = [:]
        for entry in filteredEntries {
            counts[entry.symptomType, default: 0] += 1
        }
        return counts
    }

    private var triggerCounts: [String: Int] {
        var counts: [String: Int] = [:]
        for entry in filteredEntries {
            if let trigger = entry.trigger, trigger != "Unknown" {
                counts[trigger, default: 0] += 1
            }
        }
        return counts
    }

    private var recentCompletions: Int {
        let cutoff = Calendar.current.date(byAdding: .day, value: -timeRange.days, to: Date()) ?? Date()
        return completions.filter { $0.timestamp >= cutoff }.count
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

struct StatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(.title, design: .monospaced, weight: .bold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    AnalyticsView()
        .modelContainer(for: PainEntry.self, inMemory: true)
}
