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
                frequency: "2x/day",
                formGuide: """
                1. Lie on your back with knees bent and feet flat on the floor
                2. Place arms at your sides, palms down
                3. Tighten your abdominal muscles
                4. Push your lower back into the floor (imagine flattening the curve)
                5. Hold for 5 seconds while breathing normally
                6. Relax and return to starting position

                Tips:
                • Keep movements slow and controlled
                • Don't hold your breath
                • You should feel your abs working, not your back straining
                """
            ),
            Exercise(
                name: "Knee to Chest Stretch",
                exerciseDescription: "Lie on back, pull one knee to chest. Hold 20-30 seconds each side.",
                sets: 2,
                reps: 3,
                frequency: "2x/day",
                formGuide: """
                1. Lie on your back with both knees bent
                2. Slowly bring one knee toward your chest
                3. Clasp your hands behind your thigh (not on the knee)
                4. Gently pull knee closer until you feel a stretch
                5. Hold for 20-30 seconds
                6. Lower leg slowly and repeat on other side

                Tips:
                • Keep your lower back pressed to the floor
                • Don't bounce or force the stretch
                • Breathe deeply and relax into the stretch
                """
            ),
            Exercise(
                name: "Cat-Cow Stretch",
                exerciseDescription: "On hands and knees, alternate arching and rounding back. Move slowly.",
                sets: 2,
                reps: 10,
                frequency: "daily",
                formGuide: """
                1. Start on hands and knees (tabletop position)
                2. Hands under shoulders, knees under hips
                3. COW: Inhale, drop belly, lift chest and tailbone
                4. CAT: Exhale, round spine up, tuck chin and tailbone
                5. Move smoothly between positions
                6. One complete cycle = 1 rep

                Tips:
                • Move with your breath
                • Keep movements slow and fluid
                • Feel the stretch through your entire spine
                """
            ),
            Exercise(
                name: "Bird Dog",
                exerciseDescription: "On hands and knees, extend opposite arm and leg. Hold 5 seconds. Core stability.",
                sets: 2,
                reps: 10,
                frequency: "daily",
                formGuide: """
                1. Start on hands and knees (tabletop position)
                2. Keep your back flat like a table
                3. Slowly extend right arm forward and left leg back
                4. Keep arm and leg parallel to floor
                5. Hold for 5 seconds, keeping core tight
                6. Return to start and switch sides

                Tips:
                • Don't let your hips rotate or drop
                • Keep your neck neutral (look at floor)
                • Engage your core throughout
                • Move slowly with control
                """
            ),
            Exercise(
                name: "Prone Press-ups",
                exerciseDescription: "Lie face down, press upper body up keeping hips on floor. McKenzie extension.",
                sets: 3,
                reps: 10,
                frequency: "3x/day",
                formGuide: """
                1. Lie face down with hands under shoulders
                2. Keep legs together and relaxed
                3. Slowly press upper body up using arms
                4. Keep hips and pelvis on the floor
                5. Straighten arms as much as comfortable
                6. Hold 1-2 seconds, then lower slowly

                Tips:
                • Let your lower back sag and relax
                • Don't tense your back muscles
                • Stop if you feel pain down your leg
                • This is a McKenzie extension exercise
                """
            ),
            Exercise(
                name: "Sciatic Nerve Glide",
                exerciseDescription: "Seated, extend leg while flexing foot. For L5 nerve compression relief.",
                sets: 2,
                reps: 10,
                frequency: "2x/day",
                formGuide: """
                1. Sit upright in a chair
                2. Slowly straighten one leg out in front
                3. Flex your foot (toes toward you) as leg extends
                4. Point your foot as you bend the knee back
                5. Move smoothly, don't hold the stretch
                6. Repeat on same leg, then switch

                Tips:
                • Movement should be gentle and pain-free
                • You may feel mild tension, not pain
                • Keep your back straight throughout
                • This helps mobilize the sciatic nerve
                """
            ),
            Exercise(
                name: "Wall Sits",
                exerciseDescription: "Back against wall, slide down to 90° knee bend. Hold 20-30 seconds.",
                sets: 2,
                reps: 5,
                frequency: "daily",
                formGuide: """
                1. Stand with back against a wall
                2. Feet shoulder-width apart, 2 feet from wall
                3. Slide down until thighs are parallel to floor
                4. Keep knees over ankles (not past toes)
                5. Press lower back into the wall
                6. Hold for 20-30 seconds, then slide up

                Tips:
                • Keep your weight in your heels
                • Don't go lower than 90 degrees
                • Breathe normally throughout
                • Build up hold time gradually
                """
            ),
            Exercise(
                name: "Bridges",
                exerciseDescription: "Lie on back, knees bent, lift hips. Strengthens glutes and core.",
                sets: 2,
                reps: 12,
                frequency: "daily",
                formGuide: """
                1. Lie on back with knees bent, feet flat
                2. Feet hip-width apart, arms at sides
                3. Squeeze glutes and lift hips off floor
                4. Create a straight line from knees to shoulders
                5. Hold for 2-3 seconds at the top
                6. Lower slowly back to starting position

                Tips:
                • Drive through your heels, not toes
                • Don't arch your lower back at the top
                • Keep your core engaged throughout
                • Squeeze glutes at the top of the movement
                """
            ),
        ]

        for exercise in exercises {
            context.insert(exercise)
        }
    }
}
