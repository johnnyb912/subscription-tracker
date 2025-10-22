import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {}

    func scheduleUpcomingNotifications() {
        // Clear all existing notifications
        notificationCenter.removeAllPendingNotificationRequests()

        let subscriptions = DataManager.shared.activeSubscriptions()

        for subscription in subscriptions {
            scheduleNotification(for: subscription)
        }
    }

    private func scheduleNotification(for subscription: Subscription) {
        // Schedule notification 3 days before payment
        let threeDaysBefore = Calendar.current.date(byAdding: .day, value: -3, to: subscription.nextPaymentDate)
        if let notificationDate = threeDaysBefore, notificationDate > Date() {
            createNotification(
                for: subscription,
                date: notificationDate,
                title: "Upcoming Payment",
                body: "\(subscription.name) - $\(String(format: "%.2f", subscription.cost)) due in 3 days"
            )
        }

        // Schedule notification 1 day before payment
        let oneDayBefore = Calendar.current.date(byAdding: .day, value: -1, to: subscription.nextPaymentDate)
        if let notificationDate = oneDayBefore, notificationDate > Date() {
            createNotification(
                for: subscription,
                date: notificationDate,
                title: "Payment Tomorrow",
                body: "\(subscription.name) - $\(String(format: "%.2f", subscription.cost)) due tomorrow"
            )
        }

        // Schedule notification on payment day
        if subscription.nextPaymentDate > Date() {
            createNotification(
                for: subscription,
                date: subscription.nextPaymentDate,
                title: "Payment Due Today",
                body: "\(subscription.name) - $\(String(format: "%.2f", subscription.cost)) is due today"
            )
        }
    }

    private func createNotification(for subscription: Subscription, date: Date, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let identifier = "\(subscription.id.uuidString)-\(date.timeIntervalSince1970)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}
