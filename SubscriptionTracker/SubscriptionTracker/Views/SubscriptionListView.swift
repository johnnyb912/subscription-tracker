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
            // Search and actions
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search subscriptions...", text: $searchText)
                    .textFieldStyle(.plain)

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                }

                Divider()
                    .frame(height: 20)

                Button(action: { CSVManager.shared.importFromCSV() }) {
                    Image(systemName: "square.and.arrow.down")
                }
                .buttonStyle(.plain)
                .help("Import CSV")

                Button(action: { CSVManager.shared.exportToCSV() }) {
                    Image(systemName: "square.and.arrow.up")
                }
                .buttonStyle(.plain)
                .help("Export CSV")

                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                .help("Add Subscription")
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))

            Divider()

            // Summary
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Active: \(dataManager.activeSubscriptions().count)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text("Monthly: $\(String(format: "%.2f", dataManager.totalMonthlyCost()))")
                        .font(.system(size: 13, weight: .semibold))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Yearly: $\(String(format: "%.2f", dataManager.totalYearlyCost()))")
                        .font(.system(size: 13, weight: .semibold))
                }
            }
            .padding()
            .background(Color.accentColor.opacity(0.1))

            // List
            ScrollView {
                LazyVStack(spacing: 8) {
                    if filteredSubscriptions.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "creditcard.circle")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text(searchText.isEmpty ? "No subscriptions yet" : "No results found")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            if searchText.isEmpty {
                                Button("Add Subscription") {
                                    showingAddSheet = true
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 80)
                    } else {
                        ForEach(filteredSubscriptions) { subscription in
                            SubscriptionRow(subscription: subscription) {
                                selectedSubscription = subscription
                            }
                        }
                    }
                }
                .padding()
            }
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
            HStack(spacing: 12) {
                // Category indicator
                RoundedRectangle(cornerRadius: 4)
                    .fill(category?.displayColor ?? Color.gray)
                    .frame(width: 4)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(subscription.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                        Spacer()
                        Text("$\(String(format: "%.2f", subscription.cost))")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.primary)
                    }

                    HStack {
                        Text(subscription.billingCycle.rawValue)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)

                        if let category = category {
                            Text("•")
                                .foregroundColor(.secondary)
                                .font(.system(size: 11))
                            Text(category.name)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if subscription.status == .canceled {
                            Text("Canceled")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red)
                                .cornerRadius(4)
                        }
                    }

                    HStack {
                        Text(formatNextPayment())
                            .font(.system(size: 11))
                            .foregroundColor(daysUntilPayment <= 3 && subscription.status == .active ? .orange : .secondary)

                        Spacer()

                        if !tags.isEmpty {
                            HStack(spacing: 4) {
                                ForEach(tags.prefix(2)) { tag in
                                    Text(tag.name)
                                        .font(.system(size: 9, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(tag.displayColor)
                                        .cornerRadius(4)
                                }
                                if tags.count > 2 {
                                    Text("+\(tags.count - 2)")
                                        .font(.system(size: 9))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .padding(12)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(subscription.isUpcoming && subscription.status == .active ? Color.orange : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func formatNextPayment() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        if daysUntilPayment == 0 {
            return "Due today"
        } else if daysUntilPayment == 1 {
            return "Due tomorrow"
        } else if daysUntilPayment < 0 {
            return "Overdue"
        } else if daysUntilPayment <= 7 {
            return "Due in \(daysUntilPayment) days"
        } else {
            return "Next: \(formatter.string(from: subscription.nextPaymentDate))"
        }
    }
}
