import SwiftUI

struct CalendarView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var currentMonth = Date()

    var body: some View {
        VStack(spacing: 0) {
            // Month navigation - Batman tech style
            HStack(spacing: 16) {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left.2")
                        .foregroundColor(.batCyan)
                        .imageScale(.medium)
                        .batGlow(color: .batCyan, radius: 2)
                }
                .buttonStyle(.plain)

                Spacer()

                Text(monthYearString().uppercased())
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.batTextPrimary)
                    .tracking(2)

                Spacer()

                Button(action: nextMonth) {
                    Image(systemName: "chevron.right.2")
                        .foregroundColor(.batCyan)
                        .imageScale(.medium)
                        .batGlow(color: .batCyan, radius: 2)
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(Color.batDarkGray)

            Rectangle()
                .fill(Color.batMidGray.opacity(0.5))
                .frame(height: 1)

            // Calendar grid
            VStack(spacing: 0) {
                // Weekday headers - Tech style
                HStack(spacing: 0) {
                    ForEach(["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(.batTextTertiary)
                            .tracking(1)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                }
                .background(Color.batBlack.opacity(0.5))

                Rectangle()
                    .fill(Color.batCyan.opacity(0.2))
                    .frame(height: 1)

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
                        Rectangle()
                            .fill(Color.batMidGray.opacity(0.3))
                            .frame(height: 0.5)
                    }
                }

                Spacer()
            }
            .background(Color.batBlack)
        }
        .background(Color.batBlack)
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
        VStack(alignment: .leading, spacing: 3) {
            // Day number - Batman style
            Text(dayNumber)
                .font(.system(size: 11, weight: isToday ? .bold : .medium, design: .monospaced))
                .foregroundColor(isCurrentMonth ? (isToday ? .batBlack : .batTextPrimary) : .batTextTertiary)
                .frame(width: 18, height: 18)
                .background(isToday ? Color.batCyan : Color.clear)
                .overlay(
                    Rectangle()
                        .strokeBorder(isToday ? Color.batCyan : Color.clear, lineWidth: 1)
                )
                .shadow(color: isToday ? Color.batCyan.opacity(0.6) : Color.clear, radius: 4)

            if !subscriptions.isEmpty {
                VStack(alignment: .leading, spacing: 1) {
                    ForEach(subscriptions.prefix(2)) { subscription in
                        let category = dataManager.getCategory(for: subscription)
                        HStack(spacing: 2) {
                            Rectangle()
                                .fill(category?.displayColor ?? Color.batCyan)
                                .frame(width: 3, height: 3)
                            Text(subscription.name.prefix(6).uppercased())
                                .font(.system(size: 7, design: .monospaced))
                                .lineLimit(1)
                                .foregroundColor(.batTextSecondary)
                        }
                    }

                    if subscriptions.count > 2 {
                        Text("+\(subscriptions.count - 2)")
                            .font(.system(size: 6, design: .monospaced))
                            .foregroundColor(.batTextTertiary)
                    }

                    Text("$\(String(format: "%.0f", totalCost))")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.batGreen)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .frame(height: 70)
        .padding(4)
        .background(isCurrentMonth ? Color.batDarkGray.opacity(0.4) : Color.batBlack.opacity(0.2))
        .overlay(
            Rectangle()
                .stroke(Color.batMidGray.opacity(0.3), lineWidth: 0.5)
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
