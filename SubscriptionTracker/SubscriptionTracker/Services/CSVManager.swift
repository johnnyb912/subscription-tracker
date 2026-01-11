import Foundation
import AppKit

class CSVManager {
    static let shared = CSVManager()

    private init() {}

    // MARK: - Export

    func exportToCSV() {
        let subscriptions = DataManager.shared.subscriptions
        var csvString = "Name,Cost,Billing Cycle,Next Payment Date,Status,Category,Tags,Notes\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short

        for subscription in subscriptions {
            let category = DataManager.shared.getCategory(for: subscription)?.name ?? ""
            let tags = DataManager.shared.getTags(for: subscription).map { $0.name }.joined(separator: "; ")
            let notes = subscription.notes.replacingOccurrences(of: "\"", with: "\"\"")

            csvString += "\"\(subscription.name)\","
            csvString += "\(subscription.cost),"
            csvString += "\"\(subscription.billingCycle.rawValue)\","
            csvString += "\"\(dateFormatter.string(from: subscription.nextPaymentDate))\","
            csvString += "\"\(subscription.status.rawValue)\","
            csvString += "\"\(category)\","
            csvString += "\"\(tags)\","
            csvString += "\"\(notes)\"\n"
        }

        showSavePanel(csvString: csvString)
    }

    private func showSavePanel(csvString: String) {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.nameFieldStringValue = "subscriptions.csv"
        savePanel.allowedContentTypes = [.commaSeparatedText]

        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                do {
                    try csvString.write(to: url, atomically: true, encoding: .utf8)
                    print("CSV exported successfully to \(url.path)")
                } catch {
                    print("Error saving CSV: \(error)")
                }
            }
        }
    }

    // MARK: - Import

    func importFromCSV() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.allowedContentTypes = [.commaSeparatedText]

        openPanel.begin { response in
            if response == .OK, let url = openPanel.url {
                self.parseCSV(from: url)
            }
        }
    }

    private func parseCSV(from url: URL) {
        do {
            let csvString = try String(contentsOf: url, encoding: .utf8)
            let rows = csvString.components(separatedBy: "\n").filter { !$0.isEmpty }

            guard rows.count > 1 else {
                print("CSV file is empty or invalid")
                return
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short

            // Skip header row
            for row in rows.dropFirst() {
                let columns = parseCSVRow(row)
                guard columns.count >= 5 else { continue }

                let name = columns[0]
                let cost = Double(columns[1]) ?? 0.0
                let billingCycleString = columns[2]
                let nextPaymentDateString = columns[3]
                let statusString = columns[4]
                let categoryName = columns.count > 5 ? columns[5] : ""
                let tagsString = columns.count > 6 ? columns[6] : ""
                let notes = columns.count > 7 ? columns[7] : ""

                guard let billingCycle = BillingCycle.allCases.first(where: { $0.rawValue == billingCycleString }),
                      let nextPaymentDate = dateFormatter.date(from: nextPaymentDateString),
                      let status = SubscriptionStatus(rawValue: statusString) else {
                    continue
                }

                // Find or create category
                var categoryId: UUID?
                if !categoryName.isEmpty {
                    if let existingCategory = DataManager.shared.categories.first(where: { $0.name == categoryName }) {
                        categoryId = existingCategory.id
                    } else {
                        let newCategory = Category(name: categoryName)
                        DataManager.shared.addCategory(newCategory)
                        categoryId = newCategory.id
                    }
                }

                // Find or create tags
                var tagIds: [UUID] = []
                if !tagsString.isEmpty {
                    let tagNames = tagsString.components(separatedBy: "; ")
                    for tagName in tagNames {
                        if let existingTag = DataManager.shared.tags.first(where: { $0.name == tagName }) {
                            tagIds.append(existingTag.id)
                        } else {
                            let newTag = Tag(name: tagName)
                            DataManager.shared.addTag(newTag)
                            tagIds.append(newTag.id)
                        }
                    }
                }

                let subscription = Subscription(
                    name: name,
                    cost: cost,
                    billingCycle: billingCycle,
                    nextPaymentDate: nextPaymentDate,
                    categoryId: categoryId,
                    tagIds: tagIds,
                    status: status,
                    notes: notes
                )

                DataManager.shared.addSubscription(subscription)
            }

            print("CSV imported successfully")
        } catch {
            print("Error reading CSV: \(error)")
        }
    }

    private func parseCSVRow(_ row: String) -> [String] {
        var columns: [String] = []
        var currentColumn = ""
        var insideQuotes = false

        for char in row {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                columns.append(currentColumn)
                currentColumn = ""
            } else {
                currentColumn.append(char)
            }
        }

        columns.append(currentColumn)
        return columns.map { $0.trimmingCharacters(in: .whitespaces) }
    }
}
