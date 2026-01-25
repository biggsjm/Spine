# SpineFit - Back Health Management

A minimal iOS app for managing bilateral facet arthritis and nerve compression in the lumbar spine.

## Features

### Pain Logging
- Quick entry with 0-10 pain scale
- Track location (L3, L4, L5, S1)
- Symptom types (sharp, dull, burning, radiating, etc.)
- Trigger identification (sitting, standing, bending, etc.)
- Optional notes for each entry
- Color-coded pain levels

### Exercise Tracking
- Add PT-prescribed exercises
- Track sets, reps, and frequency
- Daily completion tracking
- Exercise history

### Analytics & Trends
- Pain trend visualization with charts
- Average pain levels over time
- Good days counter (pain ≤ 3)
- Symptom breakdown
- Trigger analysis
- Exercise compliance tracking
- Configurable time ranges (7D, 14D, 30D)

## Design Philosophy

Clean, minimal interface inspired by:
- iOS Human Interface Guidelines
- Terminal aesthetics (monospaced fonts for data)
- Apps like Ivory, Reeder, and Foodnoms

## Technical Stack

- Swift + SwiftUI
- SwiftData for persistence
- Swift Charts for visualization
- iOS 17.0+

## Getting Started

1. Open `Spine.xcodeproj` in Xcode 15+
2. Select a simulator or device
3. Build and run (⌘R)

## Data Privacy

All data is stored locally on device using SwiftData. No cloud sync or external services.

## Project Structure

```
Spine/
├── SpineApp.swift          # App entry point
├── ContentView.swift       # Tab navigation
├── Models/
│   ├── PainEntry.swift     # Pain log data model
│   └── Exercise.swift      # Exercise and completion models
└── Views/
    ├── LogPainView.swift   # Pain logging interface
    ├── ExercisesView.swift # Exercise tracking
    └── AnalyticsView.swift # Trends and analytics
```

## Future Enhancements

- Apple Watch companion for quick logging
- Medication tracking
- Photo progress tracking
- Export to PDF for doctor visits
- Weather correlation
- Sitting time alerts
