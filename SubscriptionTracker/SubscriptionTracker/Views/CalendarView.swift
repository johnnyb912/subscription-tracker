import SwiftUI

struct CalendarView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var currentMonth = Date()

    var body: some View {
        VStack(spacing: 0) {
            // Month navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.plain)

                Spacer()

                Text(monthYearString())
                    .font(.system(size: 16, weight: .semibold))

                Spacer()

                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))

            Divider()

            // Calendar grid
            VStack(spacing: 0) {
                // Weekday headers
                HStack(spacing: 0) {
                    ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                }

                Divider()

                // Calendar days
                let days = generateCalendarDays()
                let rows = days.chunked(into: 7)

                ForEach(0..<rows.count, id: \.self) { rowIndex in
                    HStack(spacing: 0) {
                        ForEach(0..<rows[rowIndex].count, id: \.self) { colIndex in
                            CalendarDayCell(
                                date: rows[rowIndex][colIndex],
                                currentMonth: currentMonth,
                                subscriptions: subscriptionsForDate(rows[rowIndex][colIndex])
                            )
                        }
                    }
                    if rowIndex < rows.count - 1 {
                        Divider()
                    }
                }

                Spacer()
            }
        }
    }

    private func previousMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }

    private func nextMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }

    private func monthYearString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }

    private func generateCalendarDays() -> [Date] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        guard let startOfMonth = calendar.date(from: components) else { return [] }

        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)

        var days: [Date] = []

        // Add previous month days
        for _ in 1..<firstWeekday {
            if let date = calendar.date(byAdding: .day, value: -(firstWeekday - days.count - 1), to: startOfMonth) {
                days.append(date)
            }
        }

        // Add current month days
        for day in 1...range.count {
            if let date = calendar.date(bySetting: .day, value: day, of: startOfMonth) {
                days.append(date)
            }
        }

        // Add next month days to complete the grid
        let remainingDays = 42 - days.count
        for day in 1...remainingDays {
            if let lastDay = days.last,
               let date = calendar.date(byAdding: .day, value: day, to: lastDay) {
                days.append(date)
            }
        }

        return days
    }

    private func subscriptionsForDate(_ date: Date) -> [Subscription] {
        let calendar = Calendar.current
        return dataManager.activeSubscriptions().filter { subscription in
            calendar.isDate(subscription.nextPaymentDate, inSameDayAs: date)
        }
    }
}

struct CalendarDayCell: View {
    let date: Date
    let currentMonth: Date
    let subscriptions: [Subscription]
    @StateObject private var dataManager = DataManager.shared

    var isCurrentMonth: Bool {
        Calendar.current.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    var totalCost: Double {
        subscriptions.reduce(0) { $0 + $1.cost }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(dayNumber)
                .font(.system(size: 12, weight: isToday ? .bold : .regular))
                .foregroundColor(isCurrentMonth ? (isToday ? .white : .primary) : .secondary)
                .frame(width: 20, height: 20)
                .background(isToday ? Color.accentColor : Color.clear)
                .clipShape(Circle())

            if !subscriptions.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(subscriptions.prefix(2)) { subscription in
                        let category = dataManager.getCategory(for: subscription)
                        HStack(spacing: 2) {
                            Circle()
                                .fill(category?.displayColor ?? Color.gray)
                                .frame(width: 4, height: 4)
                            Text(subscription.name)
                                .font(.system(size: 8))
                                .lineLimit(1)
                                .foregroundColor(.primary)
                        }
                    }

                    if subscriptions.count > 2 {
                        Text("+\(subscriptions.count - 2) more")
                            .font(.system(size: 7))
                            .foregroundColor(.secondary)
                    }

                    Text("$\(String(format: "%.0f", totalCost))")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.accentColor)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .frame(height: 70)
        .padding(4)
        .background(isCurrentMonth ? Color(NSColor.controlBackgroundColor).opacity(0.3) : Color.clear)
        .overlay(
            Rectangle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
