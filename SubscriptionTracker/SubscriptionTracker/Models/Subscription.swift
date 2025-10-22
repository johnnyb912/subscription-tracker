import Foundation
import SwiftUI

enum BillingCycle: String, Codable, CaseIterable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case semiannually = "Semi-annually"
    case annually = "Annually"

    var days: Int {
        switch self {
        case .weekly: return 7
        case .monthly: return 30
        case .quarterly: return 90
        case .semiannually: return 180
        case .annually: return 365
        }
    }

    func monthlyEquivalent() -> Double {
        switch self {
        case .weekly: return 52.0 / 12.0
        case .monthly: return 1.0
        case .quarterly: return 1.0 / 3.0
        case .semiannually: return 1.0 / 6.0
        case .annually: return 1.0 / 12.0
        }
    }
}

enum SubscriptionStatus: String, Codable {
    case active = "Active"
    case canceled = "Canceled"
}

struct Tag: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var color: String // Hex color

    init(id: UUID = UUID(), name: String, color: String = "#007AFF") {
        self.id = id
        self.name = name
        self.color = color
    }

    var displayColor: Color {
        Color(hex: color) ?? .blue
    }

    static let predefined: [Tag] = [
        Tag(name: "Annual", color: "#FF3B30"),
        Tag(name: "Trial", color: "#FF9500"),
        Tag(name: "One-time", color: "#34C759")
    ]
}

struct Category: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var color: String // Hex color

    init(id: UUID = UUID(), name: String, color: String = "#007AFF") {
        self.id = id
        self.name = name
        self.color = color
    }

    var displayColor: Color {
        Color(hex: color) ?? .blue
    }

    static let predefined: [Category] = [
        Category(name: "Entertainment", color: "#FF3B30"),
        Category(name: "Productivity", color: "#007AFF"),
        Category(name: "Cloud Storage", color: "#5856D6"),
        Category(name: "Music & Audio", color: "#FF2D55"),
        Category(name: "News & Media", color: "#FF9500"),
        Category(name: "Fitness", color: "#34C759"),
        Category(name: "Development", color: "#5AC8FA"),
        Category(name: "Other", color: "#8E8E93")
    ]
}

struct Subscription: Identifiable, Codable {
    let id: UUID
    var name: String
    var cost: Double
    var billingCycle: BillingCycle
    var nextPaymentDate: Date
    var categoryId: UUID?
    var tagIds: [UUID]
    var status: SubscriptionStatus
    var notes: String
    var createdAt: Date

    init(id: UUID = UUID(),
         name: String,
         cost: Double,
         billingCycle: BillingCycle,
         nextPaymentDate: Date,
         categoryId: UUID? = nil,
         tagIds: [UUID] = [],
         status: SubscriptionStatus = .active,
         notes: String = "",
         createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.cost = cost
        self.billingCycle = billingCycle
        self.nextPaymentDate = nextPaymentDate
        self.categoryId = categoryId
        self.tagIds = tagIds
        self.status = status
        self.notes = notes
        self.createdAt = createdAt
    }

    var monthlyCost: Double {
        cost * billingCycle.monthlyEquivalent()
    }

    var yearlyCost: Double {
        monthlyCost * 12
    }

    func nextPayment(after date: Date) -> Date {
        var components = DateComponents()
        components.day = billingCycle.days
        return Calendar.current.date(byAdding: components, to: nextPaymentDate) ?? nextPaymentDate
    }

    var isUpcoming: Bool {
        let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: nextPaymentDate).day ?? 0
        return daysUntil >= 0 && daysUntil <= 7
    }
}

// Color extension to convert hex strings to SwiftUI Color
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    func toHex() -> String? {
        guard let components = NSColor(self).cgColor.components else { return nil }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}
