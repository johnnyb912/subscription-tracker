import Foundation
import SwiftUI
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()

    @Published var subscriptions: [Subscription] = []
    @Published var categories: [Category] = []
    @Published var tags: [Tag] = []

    private let subscriptionsKey = "subscriptions"
    private let categoriesKey = "categories"
    private let tagsKey = "tags"

    private init() {
        loadData()
        if categories.isEmpty {
            categories = Category.predefined
            saveCategories()
        }
        if tags.isEmpty {
            tags = Tag.predefined
            saveTags()
        }
    }

    // MARK: - Data Loading

    private func loadData() {
        loadSubscriptions()
        loadCategories()
        loadTags()
    }

    private func loadSubscriptions() {
        if let data = UserDefaults.standard.data(forKey: subscriptionsKey),
           let decoded = try? JSONDecoder().decode([Subscription].self, from: data) {
            subscriptions = decoded
        }
    }

    private func loadCategories() {
        if let data = UserDefaults.standard.data(forKey: categoriesKey),
           let decoded = try? JSONDecoder().decode([Category].self, from: data) {
            categories = decoded
        }
    }

    private func loadTags() {
        if let data = UserDefaults.standard.data(forKey: tagsKey),
           let decoded = try? JSONDecoder().decode([Tag].self, from: data) {
            tags = decoded
        }
    }

    // MARK: - Data Saving

    func saveSubscriptions() {
        if let encoded = try? JSONEncoder().encode(subscriptions) {
            UserDefaults.standard.set(encoded, forKey: subscriptionsKey)
        }
        // Reschedule notifications whenever subscriptions change
        NotificationManager.shared.scheduleUpcomingNotifications()
    }

    func saveCategories() {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: categoriesKey)
        }
    }

    func saveTags() {
        if let encoded = try? JSONEncoder().encode(tags) {
            UserDefaults.standard.set(encoded, forKey: tagsKey)
        }
    }

    // MARK: - Subscription CRUD

    func addSubscription(_ subscription: Subscription) {
        subscriptions.append(subscription)
        saveSubscriptions()
    }

    func updateSubscription(_ subscription: Subscription) {
        if let index = subscriptions.firstIndex(where: { $0.id == subscription.id }) {
            subscriptions[index] = subscription
            saveSubscriptions()
        }
    }

    func deleteSubscription(_ subscription: Subscription) {
        subscriptions.removeAll { $0.id == subscription.id }
        saveSubscriptions()
    }

    // MARK: - Category CRUD

    func addCategory(_ category: Category) {
        categories.append(category)
        saveCategories()
    }

    func updateCategory(_ category: Category) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
            saveCategories()
        }
    }

    func deleteCategory(_ category: Category) {
        categories.removeAll { $0.id == category.id }
        // Remove category reference from subscriptions
        for i in subscriptions.indices {
            if subscriptions[i].categoryId == category.id {
                subscriptions[i].categoryId = nil
            }
        }
        saveCategories()
        saveSubscriptions()
    }

    func getCategory(for subscription: Subscription) -> Category? {
        guard let categoryId = subscription.categoryId else { return nil }
        return categories.first { $0.id == categoryId }
    }

    // MARK: - Tag CRUD

    func addTag(_ tag: Tag) {
        tags.append(tag)
        saveTags()
    }

    func updateTag(_ tag: Tag) {
        if let index = tags.firstIndex(where: { $0.id == tag.id }) {
            tags[index] = tag
            saveTags()
        }
    }

    func deleteTag(_ tag: Tag) {
        tags.removeAll { $0.id == tag.id }
        // Remove tag reference from subscriptions
        for i in subscriptions.indices {
            subscriptions[i].tagIds.removeAll { $0 == tag.id }
        }
        saveTags()
        saveSubscriptions()
    }

    func getTags(for subscription: Subscription) -> [Tag] {
        subscription.tagIds.compactMap { tagId in
            tags.first { $0.id == tagId }
        }
    }

    // MARK: - Statistics

    func activeSubscriptions() -> [Subscription] {
        subscriptions.filter { $0.status == .active }
    }

    func totalMonthlyCost() -> Double {
        activeSubscriptions().reduce(0) { $0 + $1.monthlyCost }
    }

    func totalYearlyCost() -> Double {
        activeSubscriptions().reduce(0) { $0 + $1.yearlyCost }
    }

    func averageMonthlyCost() -> Double {
        let active = activeSubscriptions()
        guard !active.isEmpty else { return 0 }
        return totalMonthlyCost()
    }

    func costsByMonth() -> [Int: Double] {
        var monthCosts: [Int: Double] = [:]

        for subscription in activeSubscriptions() {
            let month = Calendar.current.component(.month, from: subscription.nextPaymentDate)
            monthCosts[month, default: 0] += subscription.cost
        }

        return monthCosts
    }

    func peakSpendingMonth() -> (month: Int, amount: Double)? {
        costsByMonth().max { $0.value < $1.value }
    }

    func costsByCategory() -> [(category: Category?, cost: Double)] {
        var categoryCosts: [UUID?: Double] = [:]

        for subscription in activeSubscriptions() {
            categoryCosts[subscription.categoryId, default: 0] += subscription.monthlyCost
        }

        return categoryCosts.map { (categoryId, cost) in
            let category = categoryId.flatMap { id in categories.first { $0.id == id } }
            return (category, cost)
        }.sorted { $0.cost > $1.cost }
    }

    func upcomingPayments(days: Int = 30) -> [Subscription] {
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: .day, value: days, to: Date()) ?? Date()

        return activeSubscriptions().filter { subscription in
            subscription.nextPaymentDate >= Date() && subscription.nextPaymentDate <= endDate
        }.sorted { $0.nextPaymentDate < $1.nextPaymentDate }
    }
}
