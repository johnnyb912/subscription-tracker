import SwiftUI

@main
struct SubscriptionTrackerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var dataManager = DataManager.shared

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
