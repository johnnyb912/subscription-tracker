import SwiftUI

struct SubscriptionListView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var showingAddSheet = false
    @State private var selectedSubscription: Subscription?
    @State private var searchText = ""

    var filteredSubscriptions: [Subscription] {
        if searchText.isEmpty {
            return dataManager.subscriptions.sorted { $0.nextPaymentDate < $1.nextPaymentDate }
        } else {
            return dataManager.subscriptions.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.nextPaymentDate < $1.nextPaymentDate }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search and actions - Batman style
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.batCyan)
                    .imageScale(.small)
                TextField("SEARCH_", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.batTextPrimary)

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.batRed)
                            .imageScale(.small)
                    }
                    .buttonStyle(.plain)
                }

                Rectangle()
                    .fill(Color.batMidGray)
                    .frame(width: 1, height: 16)

                Button(action: { CSVManager.shared.importFromCSV() }) {
                    Image(systemName: "arrow.down.doc")
                        .foregroundColor(.batCyan)
                        .imageScale(.small)
                }
                .buttonStyle(.plain)
                .batTooltip("Import", horizontalEdge: .trailing)

                Button(action: { CSVManager.shared.exportToCSV() }) {
                    Image(systemName: "arrow.up.doc")
                        .foregroundColor(.batCyan)
                        .imageScale(.small)
                }
                .buttonStyle(.plain)
                .batTooltip("Export", horizontalEdge: .trailing)

                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus.square.fill")
                        .foregroundColor(.batCyan)
                        .imageScale(.medium)
                        .batGlow(color: .batCyan, radius: 2)
                }
                .buttonStyle(.plain)
                .batTooltip("Add New", horizontalEdge: .trailing)
            }
            .padding(12)
            .background(Color.batDarkGray)

            Rectangle()
                .fill(Color.batMidGray.opacity(0.5))
                .frame(height: 1)

            // Summary - Tech display
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("[ ACTIVE ]")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.batTextTertiary)
                    Text("\(dataManager.activeSubscriptions().count.batFormatted)")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(.batCyan)
                        .batGlow(color: .batCyan, radius: 2)
                }

                Rectangle()
                    .fill(Color.batCyan.opacity(0.3))
                    .frame(width: 1, height: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text("[ MONTHLY ]")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.batTextTertiary)
                    Text("$\(dataManager.totalMonthlyCost().batFormatted)")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.batGreen)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("[ YEARLY ]")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.batTextTertiary)
                    Text("$\(dataManager.totalYearlyCost().batFormatted)")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.batYellow)
                }
            }
            .padding(12)
            .background(Color.batBlack.opacity(0.8))
            .overlay(
                Rectangle()
                    .strokeBorder(Color.batCyan.opacity(0.2), lineWidth: 1)
            )

            // List
            ScrollView {
                LazyVStack(spacing: 6) {
                    if filteredSubscriptions.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "externaldrive.badge.xmark")
                                .font(.system(size: 56))
                                .foregroundColor(.batTextTertiary)
                            Text(searchText.isEmpty ? "[ NO_DATA_FOUND ]" : "[ SEARCH_EMPTY ]")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.batTextSecondary)
                            if searchText.isEmpty {
                                Button(action: { showingAddSheet = true }) {
                                    Text("INITIALIZE_DATA")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(.batCyan)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .batButton(isSelected: true)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                    } else {
                        ForEach(filteredSubscriptions) { subscription in
                            SubscriptionRow(subscription: subscription) {
                                selectedSubscription = subscription
                            }
                        }
                    }
                }
                .padding(12)
            }
            .background(Color.batBlack)
        }
        .sheet(isPresented: $showingAddSheet) {
            SubscriptionEditView(subscription: nil)
        }
        .sheet(item: $selectedSubscription) { subscription in
            SubscriptionEditView(subscription: subscription)
        }
    }
}

struct SubscriptionRow: View {
    let subscription: Subscription
    let onTap: () -> Void
    @StateObject private var dataManager = DataManager.shared

    var category: Category? {
        dataManager.getCategory(for: subscription)
    }

    var tags: [Tag] {
        dataManager.getTags(for: subscription)
    }

    var daysUntilPayment: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: subscription.nextPaymentDate).day ?? 0
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                // Category indicator - sharp edge
                Rectangle()
                    .fill(category?.displayColor ?? Color.batCyan)
                    .frame(width: 3)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(subscription.name.uppercased())
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.batTextPrimary)
                        Spacer()
                        Text("$\(subscription.cost.batFormatted)")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.batGreen)
                            .batGlow(color: .batGreen, radius: 1)
                    }

                    HStack(spacing: 8) {
                        Text("[\(subscription.billingCycle.rawValue.uppercased())]")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.batTextSecondary)

                        if let category = category {
                            Text("|")
                                .foregroundColor(.batTextTertiary)
                                .font(.system(size: 9))
                            Text(category.name.uppercased())
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(.batTextSecondary)
                        }

                        Spacer()

                        if subscription.status == .canceled {
                            Text("OFFLINE")
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .foregroundColor(.batBlack)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.batRed)
                                .cornerRadius(1)
                        }
                    }

                    HStack {
                        Text(formatNextPayment())
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(daysUntilPayment <= 3 && subscription.status == .active ? .batYellow : .batTextTertiary)

                        Spacer()

                        if !tags.isEmpty {
                            HStack(spacing: 4) {
                                ForEach(tags.prefix(2)) { tag in
                                    Text(tag.name.uppercased())
                                        .font(.system(size: 7, weight: .bold, design: .monospaced))
                                        .foregroundColor(.batBlack)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 2)
                                        .background(tag.displayColor)
                                        .cornerRadius(1)
                                }
                                if tags.count > 2 {
                                    Text("+\(tags.count - 2)")
                                        .font(.system(size: 8, design: .monospaced))
                                        .foregroundColor(.batTextTertiary)
                                }
                            }
                        }
                    }
                }
                .padding(10)
            }
            .batCard(glowing: subscription.isUpcoming && subscription.status == .active)
        }
        .buttonStyle(.plain)
    }

    private func formatNextPayment() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short

        if daysUntilPayment == 0 {
            return "[ DUE_NOW ]"
        } else if daysUntilPayment == 1 {
            return "[ DUE_24H ]"
        } else if daysUntilPayment < 0 {
            return "[ OVERDUE ]"
        } else if daysUntilPayment <= 7 {
            return "[ T-\(daysUntilPayment.batFormatted)D ]"
        } else {
            return "NEXT: \(formatter.string(from: subscription.nextPaymentDate))"
        }
    }
}
