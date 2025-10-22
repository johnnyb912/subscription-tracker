import SwiftUI

struct StatisticsView: View {
    @StateObject private var dataManager = DataManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Overview cards
                HStack(spacing: 12) {
                    StatCard(
                        title: "Monthly",
                        value: "$\(String(format: "%.2f", dataManager.totalMonthlyCost()))",
                        icon: "calendar",
                        color: .blue
                    )

                    StatCard(
                        title: "Yearly",
                        value: "$\(String(format: "%.2f", dataManager.totalYearlyCost()))",
                        icon: "calendar.circle",
                        color: .green
                    )
                }

                HStack(spacing: 12) {
                    StatCard(
                        title: "Active",
                        value: "\(dataManager.activeSubscriptions().count)",
                        icon: "checkmark.circle",
                        color: .orange
                    )

                    StatCard(
                        title: "Total",
                        value: "\(dataManager.subscriptions.count)",
                        icon: "list.bullet",
                        color: .purple
                    )
                }

                // Radial chart
                VStack(alignment: .leading, spacing: 12) {
                    Text("Spending by Category")
                        .font(.system(size: 14, weight: .semibold))

                    if dataManager.activeSubscriptions().isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "chart.pie")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text("No active subscriptions")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        RadialChartView(data: dataManager.costsByCategory())
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(12)

                // Category breakdown
                VStack(alignment: .leading, spacing: 12) {
                    Text("Category Breakdown")
                        .font(.system(size: 14, weight: .semibold))

                    let costsByCategory = dataManager.costsByCategory()
                    let totalCost = costsByCategory.reduce(0) { $0 + $1.cost }

                    ForEach(costsByCategory.indices, id: \.self) { index in
                        let item = costsByCategory[index]
                        CategoryBreakdownRow(
                            category: item.category,
                            cost: item.cost,
                            percentage: totalCost > 0 ? (item.cost / totalCost) * 100 : 0
                        )
                    }

                    if costsByCategory.isEmpty {
                        Text("No data available")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 20)
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(12)

                // Monthly projection
                if let peak = dataManager.peakSpendingMonth() {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Peak Spending Month")
                            .font(.system(size: 14, weight: .semibold))

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(monthName(peak.month))
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Highest payment month")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Text("$\(String(format: "%.2f", peak.amount))")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }

    private func monthName(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.monthSymbols = DateFormatter().monthSymbols
        return formatter.monthSymbols[month - 1]
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }

            Text(value)
                .font(.system(size: 20, weight: .bold))

            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct RadialChartView: View {
    let data: [(category: Category?, cost: Double)]

    var totalCost: Double {
        data.reduce(0) { $0 + $1.cost }
    }

    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2 - 20

            ZStack {
                // Draw pie slices
                ForEach(data.indices, id: \.self) { index in
                    let startAngle = startAngle(for: index)
                    let endAngle = endAngle(for: index)

                    Path { path in
                        path.move(to: center)
                        path.addArc(
                            center: center,
                            radius: radius,
                            startAngle: startAngle,
                            endAngle: endAngle,
                            clockwise: false
                        )
                        path.closeSubpath()
                    }
                    .fill(data[index].category?.displayColor ?? Color.gray)
                }

                // Center circle
                Circle()
                    .fill(Color(NSColor.controlBackgroundColor))
                    .frame(width: radius * 0.6, height: radius * 0.6)
                    .overlay(
                        VStack(spacing: 4) {
                            Text("$\(String(format: "%.0f", totalCost))")
                                .font(.system(size: 20, weight: .bold))
                            Text("per month")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    )
            }
        }
        .frame(height: 220)
    }

    private func startAngle(for index: Int) -> Angle {
        let precedingCosts = data.prefix(index).reduce(0) { $0 + $1.cost }
        let percentage = totalCost > 0 ? precedingCosts / totalCost : 0
        return .degrees(percentage * 360 - 90)
    }

    private func endAngle(for index: Int) -> Angle {
        let costsUpToIndex = data.prefix(index + 1).reduce(0) { $0 + $1.cost }
        let percentage = totalCost > 0 ? costsUpToIndex / totalCost : 0
        return .degrees(percentage * 360 - 90)
    }
}

struct CategoryBreakdownRow: View {
    let category: Category?
    let cost: Double
    let percentage: Double

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(category?.displayColor ?? Color.gray)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 2) {
                Text(category?.name ?? "Uncategorized")
                    .font(.system(size: 12, weight: .medium))
                Text("\(String(format: "%.1f", percentage))%")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("$\(String(format: "%.2f", cost))")
                .font(.system(size: 13, weight: .semibold))
        }
        .padding(.vertical, 4)
    }
}
