import Foundation
import SwiftData

struct SampleData {
    static func addSampleExercises(to context: ModelContext) {
        // Common exercises for bilateral facet arthritis and L5 nerve compression
        let exercises = [
            Exercise(
                name: "Pelvic Tilts",
                exerciseDescription: "Lie on back, knees bent. Flatten lower back to floor by tightening abs. Hold 5 seconds.",
                sets: 2,
                reps: 10,
                frequency: "2x/day"
            ),
            Exercise(
                name: "Knee to Chest Stretch",
                exerciseDescription: "Lie on back, pull one knee to chest. Hold 20-30 seconds each side.",
                sets: 2,
                reps: 3,
                frequency: "2x/day"
            ),
            Exercise(
                name: "Cat-Cow Stretch",
                exerciseDescription: "On hands and knees, alternate arching and rounding back. Move slowly.",
                sets: 2,
                reps: 10,
                frequency: "daily"
            ),
            Exercise(
                name: "Bird Dog",
                exerciseDescription: "On hands and knees, extend opposite arm and leg. Hold 5 seconds. Core stability.",
                sets: 2,
                reps: 10,
                frequency: "daily"
            ),
            Exercise(
                name: "Prone Press-ups",
                exerciseDescription: "Lie face down, press upper body up keeping hips on floor. McKenzie extension.",
                sets: 3,
                reps: 10,
                frequency: "3x/day"
            ),
            Exercise(
                name: "Sciatic Nerve Glide",
                exerciseDescription: "Seated, extend leg while flexing foot. For L5 nerve compression relief.",
                sets: 2,
                reps: 10,
                frequency: "2x/day"
            ),
            Exercise(
                name: "Wall Sits",
                exerciseDescription: "Back against wall, slide down to 90° knee bend. Hold 20-30 seconds.",
                sets: 2,
                reps: 5,
                frequency: "daily"
            ),
            Exercise(
                name: "Bridges",
                exerciseDescription: "Lie on back, knees bent, lift hips. Strengthens glutes and core.",
                sets: 2,
                reps: 12,
                frequency: "daily"
            ),
        ]

        for exercise in exercises {
            context.insert(exercise)
        }
    }
}
