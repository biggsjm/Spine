import SwiftUI
import SwiftData

struct CalendarView: View {
    @Query private var entries: [PainEntry]

    @State private var selectedMonth = Date()

    var body: some View {
        NavigationStack {
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
            .navigationTitle("Pain Calendar")
            .navigationBarTitleDisplayMode(.inline)
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

struct DayCell: View {
    let date: Date
    let painLevel: Double?

    var body: some View {
        VStack(spacing: 4) {
            Text(date, format: .dateTime.day())
                .font(.system(.body, design: .default, weight: .medium))

            if let pain = painLevel {
                Circle()
                    .fill(painColor(for: Int(pain)))
                    .frame(width: 8, height: 8)
            } else {
                Circle()
                    .fill(Color(.tertiarySystemFill))
                    .frame(width: 8, height: 8)
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Calendar.current.isDateInToday(date) ? Color.blue.opacity(0.1) : Color.clear)
        )
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

struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
                .font(.system(.caption, design: .default))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    CalendarView()
        .modelContainer(for: PainEntry.self, inMemory: true)
}
