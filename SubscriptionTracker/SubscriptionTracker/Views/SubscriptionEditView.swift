import SwiftUI

struct SubscriptionEditView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var dataManager = DataManager.shared

    let subscription: Subscription?
    @State private var name: String
    @State private var cost: String
    @State private var billingCycle: BillingCycle
    @State private var nextPaymentDate: Date
    @State private var selectedCategoryId: UUID?
    @State private var selectedTagIds: Set<UUID>
    @State private var status: SubscriptionStatus
    @State private var notes: String
    @State private var showingDeleteAlert = false

    init(subscription: Subscription?) {
        self.subscription = subscription
        _name = State(initialValue: subscription?.name ?? "")
        _cost = State(initialValue: subscription != nil ? String(format: "%.2f", subscription!.cost) : "")
        _billingCycle = State(initialValue: subscription?.billingCycle ?? .monthly)
        _nextPaymentDate = State(initialValue: subscription?.nextPaymentDate ?? Date())
        _selectedCategoryId = State(initialValue: subscription?.categoryId)
        _selectedTagIds = State(initialValue: Set(subscription?.tagIds ?? []))
        _status = State(initialValue: subscription?.status ?? .active)
        _notes = State(initialValue: subscription?.notes ?? "")
    }

    var isValid: Bool {
        !name.isEmpty && Double(cost) != nil && Double(cost)! > 0
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(subscription == nil ? "New Subscription" : "Edit Subscription")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Form
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Name
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Name")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        TextField("e.g., Netflix, Spotify", text: $name)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Cost
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Cost")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        TextField("0.00", text: $cost)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Billing Cycle
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Billing Cycle")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        Picker("", selection: $billingCycle) {
                            ForEach(BillingCycle.allCases, id: \.self) { cycle in
                                Text(cycle.rawValue).tag(cycle)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.segmented)
                    }

                    // Next Payment Date
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Next Payment Date")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        DatePicker("", selection: $nextPaymentDate, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.graphical)
                    }

                    // Category
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Category")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                CategoryChip(category: nil, isSelected: selectedCategoryId == nil) {
                                    selectedCategoryId = nil
                                }
                                ForEach(dataManager.categories) { category in
                                    CategoryChip(category: category, isSelected: selectedCategoryId == category.id) {
                                        selectedCategoryId = category.id
                                    }
                                }
                            }
                        }
                    }

                    // Tags
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Tags")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(dataManager.tags) { tag in
                                    TagChip(tag: tag, isSelected: selectedTagIds.contains(tag.id)) {
                                        if selectedTagIds.contains(tag.id) {
                                            selectedTagIds.remove(tag.id)
                                        } else {
                                            selectedTagIds.insert(tag.id)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Status
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Status")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        Picker("", selection: $status) {
                            Text("Active").tag(SubscriptionStatus.active)
                            Text("Canceled").tag(SubscriptionStatus.canceled)
                        }
                        .labelsHidden()
                        .pickerStyle(.segmented)
                    }

                    // Notes
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Notes")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        TextEditor(text: $notes)
                            .frame(height: 60)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                .padding()
            }

            Divider()

            // Footer
            HStack {
                if subscription != nil {
                    Button(action: { showingDeleteAlert = true }) {
                        Text("Delete")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Button("Cancel") {
                    dismiss()
                }

                Button("Save") {
                    saveSubscription()
                }
                .disabled(!isValid)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(width: 450, height: 600)
        .alert("Delete Subscription", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let subscription = subscription {
                    dataManager.deleteSubscription(subscription)
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete this subscription?")
        }
    }

    private func saveSubscription() {
        guard let costValue = Double(cost) else { return }

        if let existing = subscription {
            let updated = Subscription(
                id: existing.id,
                name: name,
                cost: costValue,
                billingCycle: billingCycle,
                nextPaymentDate: nextPaymentDate,
                categoryId: selectedCategoryId,
                tagIds: Array(selectedTagIds),
                status: status,
                notes: notes,
                createdAt: existing.createdAt
            )
            dataManager.updateSubscription(updated)
        } else {
            let new = Subscription(
                name: name,
                cost: costValue,
                billingCycle: billingCycle,
                nextPaymentDate: nextPaymentDate,
                categoryId: selectedCategoryId,
                tagIds: Array(selectedTagIds),
                status: status,
                notes: notes
            )
            dataManager.addSubscription(new)
        }

        dismiss()
    }
}

struct CategoryChip: View {
    let category: Category?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let category = category {
                    Circle()
                        .fill(category.displayColor)
                        .frame(width: 8, height: 8)
                    Text(category.name)
                        .font(.system(size: 11))
                } else {
                    Text("None")
                        .font(.system(size: 11))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct TagChip: View {
    let tag: Tag
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Circle()
                    .fill(tag.displayColor)
                    .frame(width: 8, height: 8)
                Text(tag.name)
                    .font(.system(size: 11))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? tag.displayColor : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}
