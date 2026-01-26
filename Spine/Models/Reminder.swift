import Foundation
import SwiftData

@Model
final class Reminder {
    var title: String
    var reminderDescription: String
    var time: Date
    var isEnabled: Bool
    var repeatDaily: Bool
    var category: String // pain_log, exercise, medication

    init(title: String, reminderDescription: String, time: Date, repeatDaily: Bool = true, category: String) {
        self.title = title
        self.reminderDescription = reminderDescription
        self.time = time
        self.isEnabled = true
        self.repeatDaily = repeatDaily
        self.category = category
    }
}

extension Reminder {
    static let categories = ["Pain Log", "Exercise", "Medication"]
}
