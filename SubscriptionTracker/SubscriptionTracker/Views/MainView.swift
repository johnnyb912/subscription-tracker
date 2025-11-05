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
            // Header - Batman style
            HStack {
                Image(systemName: "shield.lefthalf.filled")
                    .foregroundColor(.batCyan)
                    .batGlow(color: .batCyan, radius: 3)

                Text("SUBSCRIPTION TRACKER")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.batTextPrimary)
                    .tracking(2)

                Spacer()

                Text("[ v1.0 ]")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(.batTextTertiary)

                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Image(systemName: "power")
                        .foregroundColor(.batRed)
                        .imageScale(.small)
                }
                .buttonStyle(.plain)
                .help("Shutdown")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.batBlack)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.batCyan.opacity(0.3)),
                alignment: .bottom
            )

            // Tab Bar - Tech style
            HStack(spacing: 2) {
                TabButton(title: "DATA", icon: "cylinder.split.1x2", isSelected: selectedTab == .subscriptions) {
                    selectedTab = .subscriptions
                }
                TabButton(title: "TIMELINE", icon: "calendar.badge.clock", isSelected: selectedTab == .calendar) {
                    selectedTab = .calendar
                }
                TabButton(title: "METRICS", icon: "chart.pie.fill", isSelected: selectedTab == .statistics) {
                    selectedTab = .statistics
                }
                TabButton(title: "CONFIG", icon: "gearshape.fill", isSelected: selectedTab == .settings) {
                    selectedTab = .settings
                }
            }
            .padding(8)
            .background(Color.batDarkGray)

            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.batMidGray.opacity(0.5))

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
            .background(Color.batBlack)
        }
        .frame(width: 450, height: 600)
        .background(Color.batBlack)
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .imageScale(.medium)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .batCyan : .batTextSecondary)
                    .batGlow(color: .batCyan, radius: isSelected ? 3 : 0)

                Text(title)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .tracking(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .batButton(isSelected: isSelected)
        }
        .buttonStyle(.plain)
    }
}
