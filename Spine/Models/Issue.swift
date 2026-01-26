import Foundation
import SwiftData

@Model
final class Issue {
    var timestamp: Date
    var title: String
    var issueDescription: String
    var category: String // bug, feature, ui, performance, other
    var severity: String // low, medium, high, critical
    var isResolved: Bool
    var resolvedAt: Date?

    init(timestamp: Date = Date(), title: String, issueDescription: String, category: String = "bug", severity: String = "medium") {
        self.timestamp = timestamp
        self.title = title
        self.issueDescription = issueDescription
        self.category = category
        self.severity = severity
        self.isResolved = false
    }

    func markResolved() {
        isResolved = true
        resolvedAt = Date()
    }

    func toggleResolved() {
        if isResolved {
            isResolved = false
            resolvedAt = nil
        } else {
            isResolved = true
            resolvedAt = Date()
        }
    }
}

extension Issue {
    static let categories = ["Bug", "Feature Request", "UI/UX", "Performance", "Other"]
    static let severities = ["Low", "Medium", "High", "Critical"]
}
