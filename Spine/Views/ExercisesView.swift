import SwiftUI
import SwiftData

// MARK: - Frequency Parsing

enum Period {
    case daily
    case weekly
}

func parseFrequency(_ frequency: String) -> (target: Int, period: Period) {
    let lower = frequency.lowercased().trimmingCharacters(in: .whitespaces)

    // Handle "daily" -> (1, .daily)
    if lower == "daily" {
        return (target: 1, period: .daily)
    }

    // Handle "Nx/day" patterns like "2x/day"
    if lower.contains("/day") {
        // Extract the number before "x/day"
        let components = lower.components(separatedBy: "x/day")
        if let firstPart = components.first, let count = Int(firstPart) {
            return (target: count, period: .daily)
        }
        return (target: 1, period: .daily)
    }

    // Handle "Nx/week" patterns like "3x/week", "5x/week"
    if lower.contains("/week") {
        // Extract the number before "x/week"
        let components = lower.components(separatedBy: "x/week")
        if let firstPart = components.first, let count = Int(firstPart) {
            return (target: count, period: .weekly)
        }
        return (target: 1, period: .weekly)
    }

    // Default to daily if can't parse
    return (target: 1, period: .daily)
}

// MARK: - ExercisesView

struct ExercisesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var exercises: [Exercise]
    @Query(sort: \ExerciseCompletion.timestamp, order: .reverse) private var completions: [ExerciseCompletion]

    @State private var showingAddExercise = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if exercises.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(exercises) { exercise in
                            ExerciseRow(
                                exercise: exercise,
                                completionsToday: completionsToday(for: exercise.name),
                                completionsThisWeek: completionsThisWeek(for: exercise.name),
                                onLog: { logExercise(exercise) }
                            )
                            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                        }
                        .onDelete(perform: deleteExercises)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddExercise = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                AddExerciseView()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.walk.circle")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("No exercises yet")
                .font(.system(.title3, design: .default, weight: .medium))
            Text("Add your PT exercises to track daily progress")
                .font(.system(.body, design: .default))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showingAddExercise = true
            } label: {
                Text("Add Exercise")
                    .font(.system(.body, design: .monospaced, weight: .medium))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 8)
        }
        .padding()
        .frame(maxHeight: .infinity)
    }

    private func completionsToday(for exerciseName: String) -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        return completions.filter { completion in
            completion.exerciseName == exerciseName &&
            completion.timestamp >= startOfDay
        }.count
    }

    private func completionsThisWeek(for exerciseName: String) -> Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        return completions.filter { completion in
            completion.exerciseName == exerciseName &&
            completion.timestamp >= startOfWeek
        }.count
    }

    private func logExercise(_ exercise: Exercise) {
        let completion = ExerciseCompletion(
            exerciseName: exercise.name,
            sets: exercise.sets,
            reps: exercise.reps
        )
        modelContext.insert(completion)
        exercise.lastCompletedDate = Date()

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    private func deleteExercises(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(exercises[index])
        }
    }
}

// MARK: - ExerciseRow

struct ExerciseRow: View {
    @Bindable var exercise: Exercise
    let completionsToday: Int
    let completionsThisWeek: Int
    let onLog: () -> Void

    @State private var showingDetail = false
    @State private var animateLog = false

    private var parsedFrequency: (target: Int, period: Period) {
        parseFrequency(exercise.frequency)
    }

    private var currentCount: Int {
        switch parsedFrequency.period {
        case .daily:
            return completionsToday
        case .weekly:
            return completionsThisWeek
        }
    }

    private var targetCount: Int {
        parsedFrequency.target
    }

    private var isGoalMet: Bool {
        currentCount >= targetCount
    }

    private var progressText: String {
        switch parsedFrequency.period {
        case .daily:
            if targetCount == 1 {
                return isGoalMet ? "Done today" : "Not done"
            } else {
                return "\(currentCount)/\(targetCount) today"
            }
        case .weekly:
            return "\(currentCount)/\(targetCount) this week"
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Log button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    animateLog = true
                }
                onLog()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    animateLog = false
                }
            }) {
                ZStack {
                    Circle()
                        .fill(isGoalMet ? Color.green.opacity(0.15) : Color.blue.opacity(0.15))
                        .frame(width: 44, height: 44)

                    if isGoalMet {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.green)
                    } else {
                        Text("+1")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.blue)
                    }
                }
                .scaleEffect(animateLog ? 1.2 : 1.0)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(exercise.name)
                        .font(.system(.body, design: .default, weight: .medium))

                    Spacer()

                    Text(progressText)
                        .font(.system(.caption, design: .monospaced, weight: .medium))
                        .foregroundStyle(isGoalMet ? .green : .secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(isGoalMet ? Color.green.opacity(0.1) : Color(.tertiarySystemFill))
                        .clipShape(Capsule())
                }

                if !exercise.exerciseDescription.isEmpty {
                    Text(exercise.exerciseDescription)
                        .font(.system(.caption, design: .default))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 16) {
                    Label("\(exercise.sets) × \(exercise.reps)", systemImage: "repeat")
                    Label(exercise.frequency, systemImage: "calendar")
                }
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)

                if let lastDate = exercise.lastCompletedDate {
                    Text("Last: \(lastDate, style: .relative)")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.tertiary)
                }

                if !exercise.formGuide.isEmpty {
                    Button {
                        showingDetail = true
                    } label: {
                        Label("How to perform", systemImage: "info.circle")
                            .font(.system(.caption, design: .default, weight: .medium))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                    .padding(.top, 4)
                }
            }
        }
        .sheet(isPresented: $showingDetail) {
            ExerciseDetailView(exercise: exercise)
        }
    }
}

// MARK: - ExerciseDetailView

struct ExerciseDetailView: View {
    let exercise: Exercise
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(exercise.name)
                            .font(.system(.title2, design: .default, weight: .bold))

                        Text(exercise.exerciseDescription)
                            .font(.system(.body, design: .default))
                            .foregroundStyle(.secondary)

                        HStack(spacing: 16) {
                            Label("\(exercise.sets) sets", systemImage: "number")
                            Label("\(exercise.reps) reps", systemImage: "repeat")
                            Label(exercise.frequency, systemImage: "calendar")
                        }
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                    }
                    .padding(.horizontal)

                    Divider()

                    // Form Guide
                    if !exercise.formGuide.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("How to Perform", systemImage: "figure.walk")
                                .font(.system(.headline, design: .default, weight: .semibold))
                                .foregroundStyle(.blue)

                            Text(exercise.formGuide)
                                .font(.system(.body, design: .default))
                                .lineSpacing(4)
                        }
                        .padding(.horizontal)
                    }

                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("Exercise Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - AddExerciseView

struct AddExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name = ""
    @State private var description = ""
    @State private var sets = 3
    @State private var reps = 10
    @State private var frequency = "daily"
    @State private var formGuide = ""

    let frequencies = ["daily", "2x/day", "3x/week", "5x/week"]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Exercise name", text: $name)
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...5)
                }

                Section {
                    Stepper("Sets: \(sets)", value: $sets, in: 1...10)
                    Stepper("Reps: \(reps)", value: $reps, in: 1...50)
                    Picker("Frequency", selection: $frequency) {
                        ForEach(frequencies, id: \.self) { freq in
                            Text(freq).tag(freq)
                        }
                    }
                }

                Section {
                    TextField("Form guide (optional)", text: $formGuide, axis: .vertical)
                        .lineLimit(5...10)
                } header: {
                    Text("How to Perform")
                } footer: {
                    Text("Add step-by-step instructions for proper form")
                }
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addExercise()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func addExercise() {
        let exercise = Exercise(
            name: name,
            exerciseDescription: description,
            sets: sets,
            reps: reps,
            frequency: frequency,
            formGuide: formGuide
        )
        modelContext.insert(exercise)
        dismiss()
    }
}

#Preview {
    ExercisesView()
        .modelContainer(for: Exercise.self, inMemory: true)
}
