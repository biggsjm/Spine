import Foundation
import SwiftData

@Model
final class PainEntry {
    var timestamp: Date
    var level: Int // 0-10 scale
    var location: String // L3, L4, L5, S1, or multiple
    var symptomType: String // sharp, dull, burning, numbness, tingling, radiating
    var trigger: String? // sitting, standing, walking, bending, etc.
    var notes: String?

    init(timestamp: Date = Date(), level: Int, location: String, symptomType: String, trigger: String? = nil, notes: String? = nil) {
        self.timestamp = timestamp
        self.level = level
        self.location = location
        self.symptomType = symptomType
        self.trigger = trigger
        self.notes = notes
    }
}

extension PainEntry {
    static let locations = ["L3", "L4", "L5", "S1", "L3-L4", "L4-L5", "L5-S1", "Multiple", "Radiating"]
    static let symptomTypes = ["Sharp", "Dull", "Burning", "Numbness", "Tingling", "Radiating", "Aching", "Stabbing"]
    static let triggers = ["Sitting", "Standing", "Walking", "Bending", "Lifting", "Twisting", "Morning", "Evening", "Weather", "Unknown"]
}
