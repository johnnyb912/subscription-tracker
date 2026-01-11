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
            // Header - Batman style
            HStack {
                Image(systemName: subscription == nil ? "plus.app" : "pencil.line")
                    .foregroundColor(.batCyan)
                    .batGlow(color: .batCyan, radius: 2)

                Text(subscription == nil ? "[ NEW_RECORD ]" : "[ EDIT_RECORD ]")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.batTextPrimary)
                    .tracking(2)

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.batRed)
                        .imageScale(.small)
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(Color.batBlack)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.batCyan.opacity(0.3)),
                alignment: .bottom
            )

            // Form - Batman tech style
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    // Name
                    VStack(alignment: .leading, spacing: 6) {
                        Text("[ NAME ]")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.batTextTertiary)
                            .tracking(1)
                        TextField("ENTER_NAME", text: $name)
                            .textFieldStyle(.plain)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.batTextPrimary)
                            .padding(10)
                            .background(Color.batDarkGray)
                            .overlay(
                                Rectangle()
                                    .strokeBorder(Color.batMidGray.opacity(0.5), lineWidth: 1)
                            )
                    }

                    // Cost
                    VStack(alignment: .leading, spacing: 6) {
                        Text("[ COST ]")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.batTextTertiary)
                            .tracking(1)
                        TextField("0.00", text: $cost)
                            .textFieldStyle(.plain)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.batGreen)
                            .padding(10)
                            .background(Color.batDarkGray)
                            .overlay(
                                Rectangle()
                                    .strokeBorder(Color.batMidGray.opacity(0.5), lineWidth: 1)
                            )
                    }

                    // Billing Cycle
                    VStack(alignment: .leading, spacing: 6) {
                        Text("[ BILLING_CYCLE ]")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.batTextTertiary)
                            .tracking(1)
                        Picker("", selection: $billingCycle) {
                            ForEach(BillingCycle.allCases, id: \.self) { cycle in
                                Text(cycle.rawValue.uppercased()).tag(cycle)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.segmented)
                    }

                    // Next Payment Date
                    VStack(alignment: .leading, spacing: 6) {
                        Text("[ NEXT_PAYMENT ]")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.batTextTertiary)
                            .tracking(1)
                        DatePicker("", selection: $nextPaymentDate, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.graphical)
                            .colorScheme(.dark)
                    }

                    // Category
                    VStack(alignment: .leading, spacing: 6) {
                        Text("[ CATEGORY ]")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.batTextTertiary)
                            .tracking(1)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
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
                        Text("[ TAGS ]")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.batTextTertiary)
                            .tracking(1)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
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
                        Text("[ STATUS ]")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.batTextTertiary)
                            .tracking(1)
                        Picker("", selection: $status) {
                            Text("ACTIVE").tag(SubscriptionStatus.active)
                            Text("OFFLINE").tag(SubscriptionStatus.canceled)
                        }
                        .labelsHidden()
                        .pickerStyle(.segmented)
                    }

                    // Notes
                    VStack(alignment: .leading, spacing: 6) {
                        Text("[ NOTES ]")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.batTextTertiary)
                            .tracking(1)
                        TextEditor(text: $notes)
                            .frame(height: 60)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.batTextSecondary)
                            .scrollContentBackground(.hidden)
                            .padding(8)
                            .background(Color.batDarkGray)
                            .overlay(
                                Rectangle()
                                    .strokeBorder(Color.batMidGray.opacity(0.5), lineWidth: 1)
                            )
                    }
                }
                .padding(14)
            }
            .background(Color.batBlack)

            Rectangle()
                .fill(Color.batCyan.opacity(0.3))
                .frame(height: 1)

            // Footer - Batman action bar
            HStack(spacing: 12) {
                if subscription != nil {
                    Button(action: { showingDeleteAlert = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "trash")
                                .imageScale(.small)
                            Text("DELETE")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(.batRed)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.batDarkGray)
                        .overlay(
                            Rectangle()
                                .strokeBorder(Color.batRed.opacity(0.5), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Button(action: { dismiss() }) {
                    Text("CANCEL")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.batTextSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.batDarkGray)
                        .overlay(
                            Rectangle()
                                .strokeBorder(Color.batMidGray.opacity(0.5), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                Button(action: { saveSubscription() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark")
                            .imageScale(.small)
                        Text("SAVE")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(isValid ? .batBlack : .batTextTertiary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(isValid ? Color.batCyan : Color.batDarkGray)
                    .overlay(
                        Rectangle()
                            .strokeBorder(isValid ? Color.batCyan : Color.batMidGray.opacity(0.5), lineWidth: 1)
                    )
                    .shadow(color: isValid ? Color.batCyan.opacity(0.5) : Color.clear, radius: 4)
                }
                .buttonStyle(.plain)
                .disabled(!isValid)
            }
            .padding(12)
            .background(Color.batBlack)
        }
        .frame(width: 450, height: 600)
        .background(Color.batBlack)
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
                    Rectangle()
                        .fill(category.displayColor)
                        .frame(width: 6, height: 6)
                    Text(category.name.uppercased())
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                } else {
                    Text("NONE")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? Color.batCyan : Color.batDarkGray)
            .foregroundColor(isSelected ? .batBlack : .batTextSecondary)
            .overlay(
                Rectangle()
                    .strokeBorder(isSelected ? Color.batCyan : Color.batMidGray.opacity(0.5), lineWidth: 1)
            )
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
                Rectangle()
                    .fill(tag.displayColor)
                    .frame(width: 6, height: 6)
                Text(tag.name.uppercased())
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? tag.displayColor : Color.batDarkGray)
            .foregroundColor(isSelected ? .batBlack : .batTextSecondary)
            .overlay(
                Rectangle()
                    .strokeBorder(isSelected ? tag.displayColor : Color.batMidGray.opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
