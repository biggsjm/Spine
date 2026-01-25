import Foundation
import SwiftData

@Model
final class Exercise {
    var name: String
    var exerciseDescription: String
    var sets: Int
    var reps: Int
    var isCompleted: Bool
    var completedAt: Date?
    var lastCompletedDate: Date?
    var frequency: String // daily, 2x/day, 3x/week, etc.

    init(name: String, exerciseDescription: String, sets: Int, reps: Int, frequency: String = "daily") {
        self.name = name
        self.exerciseDescription = exerciseDescription
        self.sets = sets
        self.reps = reps
        self.isCompleted = false
        self.frequency = frequency
    }

    func markCompleted() {
        isCompleted = true
        completedAt = Date()
        lastCompletedDate = Date()
    }

    func resetDaily() {
        guard let lastDate = lastCompletedDate else { return }
        if !Calendar.current.isDateInToday(lastDate) {
            isCompleted = false
            completedAt = nil
        }
    }
}

@Model
final class ExerciseCompletion {
    var timestamp: Date
    var exerciseName: String
    var sets: Int
    var reps: Int

    init(timestamp: Date = Date(), exerciseName: String, sets: Int, reps: Int) {
        self.timestamp = timestamp
        self.exerciseName = exerciseName
        self.sets = sets
        self.reps = reps
    }
}
