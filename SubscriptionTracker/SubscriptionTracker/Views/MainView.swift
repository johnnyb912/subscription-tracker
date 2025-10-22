import SwiftUI

enum MainTab {
    case subscriptions
    case calendar
    case statistics
    case settings
}

struct MainView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var selectedTab: MainTab = .subscriptions

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Subscription Tracker")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .imageScale(.medium)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))

            // Tab Bar
            HStack(spacing: 0) {
                TabButton(title: "Subscriptions", icon: "list.bullet.rectangle", isSelected: selectedTab == .subscriptions) {
                    selectedTab = .subscriptions
                }
                TabButton(title: "Calendar", icon: "calendar", isSelected: selectedTab == .calendar) {
                    selectedTab = .calendar
                }
                TabButton(title: "Statistics", icon: "chart.pie", isSelected: selectedTab == .statistics) {
                    selectedTab = .statistics
                }
                TabButton(title: "Settings", icon: "gear", isSelected: selectedTab == .settings) {
                    selectedTab = .settings
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))

            Divider()

            // Content
            Group {
                switch selectedTab {
                case .subscriptions:
                    SubscriptionListView()
                case .calendar:
                    CalendarView()
                case .statistics:
                    StatisticsView()
                case .settings:
                    SettingsView()
                }
            }
        }
        .frame(width: 450, height: 600)
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .imageScale(.medium)
                Text(title)
                    .font(.system(size: 10))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .foregroundColor(isSelected ? .accentColor : .gray)
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}
