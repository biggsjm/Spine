import SwiftUI
import SwiftData
import Charts

struct HistoryView: View {
    @State private var selectedView: HistoryTab = .calendar

    enum HistoryTab: String, CaseIterable {
        case calendar = "Calendar"
        case trends = "Trends"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("View", selection: $selectedView) {
                    ForEach(HistoryTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                switch selectedView {
                case .trends:
                    TrendsContent()
                case .calendar:
                    CalendarContent()
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - TrendsContent (extracted from AnalyticsView)

struct TrendsContent: View {
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

// MARK: - CalendarContent (extracted from CalendarView)

struct CalendarContent: View {
    @Query private var entries: [PainEntry]

    @State private var selectedMonth = Date()

    var body: some View {
        VStack(spacing: 0) {
            // Month selector
            HStack {
                Button {
                    changeMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }

                Spacer()

                Text(selectedMonth, format: .dateTime.month(.wide).year())
                    .font(.system(.title2, design: .default, weight: .semibold))

                Spacer()

                Button {
                    changeMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                }
            }
            .padding()

            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                // Day headers
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.system(.caption, design: .monospaced, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }

                // Calendar days
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        DayCell(date: date, painLevel: averagePainForDay(date))
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
            .padding(.horizontal)

            // Legend
            VStack(alignment: .leading, spacing: 12) {
                Text("PAIN LEVEL")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)

                HStack(spacing: 16) {
                    LegendItem(color: .green, label: "Low (0-2)")
                    LegendItem(color: .yellow, label: "Mild (3-4)")
                    LegendItem(color: .orange, label: "Moderate (5-6)")
                    LegendItem(color: .red, label: "Severe (7-8)")
                    LegendItem(color: .purple, label: "Extreme (9-10)")
                }

                HStack(spacing: 16) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(.tertiarySystemFill))
                            .frame(width: 12, height: 12)
                        Text("No data")
                            .font(.system(.caption, design: .default))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()

            Spacer()
        }
    }

    private var daysInMonth: [Date?] {
        let calendar = Calendar.current
        let interval = calendar.dateInterval(of: .month, for: selectedMonth)!
        let firstDay = interval.start
        let lastDay = calendar.date(byAdding: .day, value: -1, to: interval.end)!

        var days: [Date?] = []

        // Add empty cells for days before the month starts
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        for _ in 1..<firstWeekday {
            days.append(nil)
        }

        // Add all days in the month
        var currentDay = firstDay
        while currentDay <= lastDay {
            days.append(currentDay)
            currentDay = calendar.date(byAdding: .day, value: 1, to: currentDay)!
        }

        return days
    }

    private func averagePainForDay(_ date: Date) -> Double? {
        let calendar = Calendar.current
        let dayEntries = entries.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }

        guard !dayEntries.isEmpty else { return nil }

        let sum = dayEntries.reduce(0) { $0 + $1.level }
        return Double(sum) / Double(dayEntries.count)
    }

    private func changeMonth(by value: Int) {
        let calendar = Calendar.current
        if let newMonth = calendar.date(byAdding: .month, value: value, to: selectedMonth) {
            selectedMonth = newMonth
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: PainEntry.self, inMemory: true)
}
