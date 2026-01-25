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
                                completeExercise(exercise)
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

    private func completeExercise(_ exercise: Exercise) {
        let completion = ExerciseCompletion(
            exerciseName: exercise.name,
            sets: exercise.sets,
            reps: exercise.reps
        )
        modelContext.insert(completion)
        exercise.markCompleted()

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
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
            }

            Spacer()
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
            frequency: frequency
        )
        modelContext.insert(exercise)
        dismiss()
    }
}

#Preview {
    ExercisesView()
        .modelContainer(for: Exercise.self, inMemory: true)
}
