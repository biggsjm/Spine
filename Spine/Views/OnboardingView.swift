import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 16) {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue)

                    Text("Welcome to SpineFit")
                        .font(.system(.largeTitle, design: .default, weight: .bold))

                    Text("Manage your back health with daily tracking and insights")
                        .font(.system(.body, design: .default))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                VStack(alignment: .leading, spacing: 20) {
                    FeatureRow(
                        icon: "square.and.pencil",
                        title: "Quick Logging",
                        description: "Track pain levels, locations, and triggers in seconds"
                    )
                    FeatureRow(
                        icon: "figure.walk",
                        title: "Exercise Tracking",
                        description: "Monitor PT exercises and build consistency"
                    )
                    FeatureRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Trend Analysis",
                        description: "Visualize patterns and identify what helps"
                    )
                    FeatureRow(
                        icon: "lock.shield",
                        title: "Private & Secure",
                        description: "All data stays on your device"
                    )
                }
                .padding(.horizontal, 32)

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        SampleData.addSampleExercises(to: modelContext)
                        completeOnboarding()
                    } label: {
                        Text("Add Sample Exercises")
                            .font(.system(.body, design: .monospaced, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        completeOnboarding()
                    } label: {
                        Text("Skip")
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        dismiss()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(.blue)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.body, design: .default, weight: .semibold))
                Text(description)
                    .font(.system(.caption, design: .default))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: Exercise.self, inMemory: true)
}
