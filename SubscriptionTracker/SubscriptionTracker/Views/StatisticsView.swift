import SwiftUI

struct StatisticsView: View {
    @StateObject private var dataManager = DataManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Overview cards - Batman tech style
                HStack(spacing: 8) {
                    StatCard(
                        title: "MONTHLY",
                        value: "$\(dataManager.totalMonthlyCost().batFormatted)",
                        icon: "gauge.with.dots.needle.67percent",
                        color: .batCyan
                    )

                    StatCard(
                        title: "YEARLY",
                        value: "$\(dataManager.totalYearlyCost().batFormatted)",
                        icon: "chart.line.uptrend.xyaxis",
                        color: .batGreen
                    )
                }

                HStack(spacing: 8) {
                    StatCard(
                        title: "ACTIVE",
                        value: "\(dataManager.activeSubscriptions().count.batFormatted)",
                        icon: "bolt.circle",
                        color: .batYellow
                    )

                    StatCard(
                        title: "TOTAL",
                        value: "\(dataManager.subscriptions.count.batFormatted)",
                        icon: "square.stack.3d.up",
                        color: .batBlue
                    )
                }

                // Radial chart - Glowing effect
                VStack(alignment: .leading, spacing: 10) {
                    Text("[ COST DISTRIBUTION ]")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.batTextPrimary)
                        .tracking(2)

                    if dataManager.activeSubscriptions().isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "chart.pie.fill")
                                .font(.system(size: 56))
                                .foregroundColor(.batTextTertiary)
                            Text("[ NO ACTIVE DATA ]")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.batTextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        RadialChartView(data: dataManager.costsByCategory())
                    }
                }
                .padding(14)
                .batCard(glowing: true)

                // Category breakdown - Tech list
                VStack(alignment: .leading, spacing: 10) {
                    Text("[ CATEGORY ANALYSIS ]")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.batTextPrimary)
                        .tracking(2)

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
                        Text("[ NO CATEGORY DATA ]")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.batTextSecondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 20)
                    }
                }
                .padding(14)
                .batCard()

                // Peak spending - Alert style
                if let peak = dataManager.peakSpendingMonth() {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("[ PEAK EXPENDITURE ]")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.batTextPrimary)
                            .tracking(2)

                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(monthName(peak.month).uppercased())
                                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                                    .foregroundColor(.batYellow)
                                    .batGlow(color: .batYellow, radius: 2)
                                Text("HIGHEST MONTHLY CHARGE")
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundColor(.batTextTertiary)
                            }

                            Spacer()

                            Text("$\(peak.amount.batFormatted)")
                                .font(.system(size: 22, weight: .bold, design: .monospaced))
                                .foregroundColor(.batRed)
                                .batGlow(color: .batRed, radius: 2)
                        }
                    }
                    .padding(14)
                    .batCard(glowing: true)
                }
            }
            .padding(12)
        }
        .background(Color.batBlack)
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
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .batGlow(color: color, radius: 2)
                    .imageScale(.medium)
                Spacer()
            }

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .batGlow(color: color, radius: 1)

            Text(title)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.batTextTertiary)
                .tracking(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .batCard()
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
                // Draw pie slices with glow
                ForEach(data.indices, id: \.self) { index in
                    let startAngle = startAngle(for: index)
                    let endAngle = endAngle(for: index)
                    let segmentColor = data[index].category?.displayColor ?? Color.batCyan

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
                    .fill(segmentColor)
                    .shadow(color: segmentColor.opacity(0.4), radius: 4)
                }

                // Center circle - Batman tech display
                Circle()
                    .fill(Color.batBlack)
                    .frame(width: radius * 0.6, height: radius * 0.6)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.batCyan.opacity(0.3), lineWidth: 1)
                    )
                    .overlay(
                        VStack(spacing: 2) {
                            Text("$\(totalCost.batFormatted)")
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundColor(.batCyan)
                                .batGlow(color: .batCyan, radius: 2)
                            Text("/ MONTH")
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundColor(.batTextTertiary)
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
        HStack(spacing: 10) {
            // Indicator - sharp square instead of circle
            Rectangle()
                .fill(category?.displayColor ?? Color.batCyan)
                .frame(width: 8, height: 8)
                .shadow(color: (category?.displayColor ?? Color.batCyan).opacity(0.6), radius: 3)

            VStack(alignment: .leading, spacing: 1) {
                Text((category?.name ?? "UNCATEGORIZED").uppercased())
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.batTextPrimary)
                Text("\(String(format: "%.1f", percentage))%")
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundColor(.batTextTertiary)
            }

            Spacer()

            Text("$\(cost.batFormatted)")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.batGreen)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(Color.batMidGray.opacity(0.3))
        .overlay(
            Rectangle()
                .strokeBorder(Color.batMidGray.opacity(0.5), lineWidth: 1)
        )
    }
}
