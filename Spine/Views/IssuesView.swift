import SwiftUI
import SwiftData

struct IssuesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Issue.timestamp, order: .reverse) private var issues: [Issue]

    @State private var showingAddIssue = false
    @State private var showingShareSheet = false
    @State private var exportText = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if issues.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(issues) { issue in
                            IssueRow(issue: issue)
                                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                        }
                        .onDelete(perform: deleteIssues)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Beta Issues")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !issues.isEmpty {
                        Button {
                            exportIssues()
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddIssue = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddIssue) {
                AddIssueView()
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: [exportText])
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "ladybug.circle")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("No issues logged")
                .font(.system(.title3, design: .default, weight: .medium))
            Text("Track bugs and feature requests during beta testing")
                .font(.system(.body, design: .default))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showingAddIssue = true
            } label: {
                Text("Log Issue")
                    .font(.system(.body, design: .monospaced, weight: .medium))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 8)
        }
        .padding()
        .frame(maxHeight: .infinity)
    }

    private func exportIssues() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        var text = "MyBackFit Beta Issues Export\n"
        text += "Generated: \(dateFormatter.string(from: Date()))\n"
        text += "Total Issues: \(issues.count)\n"
        text += "Open: \(issues.filter { !$0.isResolved }.count)\n"
        text += "Resolved: \(issues.filter { $0.isResolved }.count)\n"
        text += "\n" + String(repeating: "=", count: 50) + "\n\n"

        for (index, issue) in issues.enumerated() {
            text += "Issue #\(index + 1)\n"
            text += "Status: \(issue.isResolved ? "✓ Resolved" : "○ Open")\n"
            text += "Category: \(issue.category)\n"
            text += "Severity: \(issue.severity)\n"
            text += "Title: \(issue.title)\n"
            text += "Description: \(issue.issueDescription)\n"
            text += "Reported: \(dateFormatter.string(from: issue.timestamp))\n"
            if let resolved = issue.resolvedAt {
                text += "Resolved: \(dateFormatter.string(from: resolved))\n"
            }
            text += "\n" + String(repeating: "-", count: 50) + "\n\n"
        }

        exportText = text
        showingShareSheet = true
    }

    private func deleteIssues(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(issues[index])
        }
    }
}

struct IssueRow: View {
    @Bindable var issue: Issue

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Button(action: { issue.markResolved() }) {
                Image(systemName: issue.isResolved ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 28))
                    .foregroundStyle(issue.isResolved ? .green : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 8) {
                Text(issue.title)
                    .font(.system(.body, design: .default, weight: .medium))
                    .strikethrough(issue.isResolved)

                Text(issue.issueDescription)
                    .font(.system(.caption, design: .default))
                    .foregroundStyle(.secondary)
                    .lineLimit(3)

                HStack(spacing: 12) {
                    Label(issue.category, systemImage: categoryIcon(issue.category))
                    Label(issue.severity, systemImage: severityIcon(issue.severity))
                    Text(issue.timestamp, style: .relative)
                }
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.tertiary)
            }

            Spacer()
        }
    }

    private func categoryIcon(_ category: String) -> String {
        switch category.lowercased() {
        case "bug": return "ladybug.fill"
        case "feature request": return "lightbulb.fill"
        case "ui/ux": return "paintbrush.fill"
        case "performance": return "speedometer"
        default: return "questionmark.circle.fill"
        }
    }

    private func severityIcon(_ severity: String) -> String {
        switch severity.lowercased() {
        case "critical": return "exclamationmark.3"
        case "high": return "exclamationmark.2"
        case "medium": return "exclamationmark"
        default: return "info.circle"
        }
    }
}

struct AddIssueView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @FocusState private var isDescriptionFocused: Bool

    @State private var title = ""
    @State private var description = ""
    @State private var category = "Bug"
    @State private var severity = "Medium"

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Issue title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(5...10)
                        .focused($isDescriptionFocused)
                }

                Section {
                    Picker("Category", selection: $category) {
                        ForEach(Issue.categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    Picker("Severity", selection: $severity) {
                        ForEach(Issue.severities, id: \.self) { sev in
                            Text(sev).tag(sev)
                        }
                    }
                }
            }
            .navigationTitle("Log Issue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addIssue()
                    }
                    .disabled(title.isEmpty)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isDescriptionFocused = false
                    }
                }
            }
        }
    }

    private func addIssue() {
        let issue = Issue(
            title: title,
            issueDescription: description,
            category: category,
            severity: severity
        )
        modelContext.insert(issue)
        dismiss()
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    IssuesView()
        .modelContainer(for: Issue.self, inMemory: true)
}
