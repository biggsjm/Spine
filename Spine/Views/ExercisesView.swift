import SwiftUI
import SwiftData

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
                            ExerciseRow(exercise: exercise) {
                                toggleExercise(exercise)
                            }
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

    private func toggleExercise(_ exercise: Exercise) {
        if !exercise.isCompleted {
            // Only log completion when marking as complete
            let completion = ExerciseCompletion(
                exerciseName: exercise.name,
                sets: exercise.sets,
                reps: exercise.reps
            )
            modelContext.insert(completion)

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
        exercise.toggleCompleted()
    }

    private func deleteExercises(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(exercises[index])
        }
    }
}

struct ExerciseRow: View {
    @Bindable var exercise: Exercise
    let onComplete: () -> Void
    @State private var showingDetail = false

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Button(action: onComplete) {
                Image(systemName: exercise.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 28))
                    .foregroundStyle(exercise.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 8) {
                Text(exercise.name)
                    .font(.system(.body, design: .default, weight: .medium))

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

            Spacer()
        }
        .sheet(isPresented: $showingDetail) {
            ExerciseDetailView(exercise: exercise)
        }
    }
}

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
