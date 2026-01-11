import SwiftUI

enum SettingsSection {
    case categories
    case tags
}

struct SettingsView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var selectedSection: SettingsSection = .categories
    @State private var showingAddCategory = false
    @State private var showingAddTag = false
    @State private var editingCategory: Category?
    @State private var editingTag: Tag?

    var body: some View {
        VStack(spacing: 0) {
            // Section selector - Batman style
            HStack(spacing: 2) {
                Button(action: { selectedSection = .categories }) {
                    Text("CATEGORIES")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .tracking(1)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .batButton(isSelected: selectedSection == .categories)
                }
                .buttonStyle(.plain)

                Button(action: { selectedSection = .tags }) {
                    Text("TAGS")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .tracking(1)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .batButton(isSelected: selectedSection == .tags)
                }
                .buttonStyle(.plain)
            }
            .padding(8)
            .background(Color.batDarkGray)

            Rectangle()
                .fill(Color.batMidGray.opacity(0.5))
                .frame(height: 1)

            // Content
            ScrollView {
                VStack(spacing: 12) {
                    if selectedSection == .categories {
                        categoriesSection
                    } else {
                        tagsSection
                    }
                }
                .padding(12)
            }
            .background(Color.batBlack)
        }
        .background(Color.batBlack)
        .sheet(isPresented: $showingAddCategory) {
            CategoryEditView(category: nil)
        }
        .sheet(isPresented: $showingAddTag) {
            TagEditView(tag: nil)
        }
        .sheet(item: $editingCategory) { category in
            CategoryEditView(category: category)
        }
        .sheet(item: $editingTag) { tag in
            TagEditView(tag: tag)
        }
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("[ CATEGORY DATABASE ]")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.batTextPrimary)
                    .tracking(2)
                Spacer()
                Button(action: { showingAddCategory = true }) {
                    Image(systemName: "plus.square.fill")
                        .foregroundColor(.batCyan)
                        .imageScale(.medium)
                        .batGlow(color: .batCyan, radius: 2)
                }
                .buttonStyle(.plain)
            }

            if dataManager.categories.isEmpty {
                VStack(spacing: 14) {
                    Image(systemName: "folder.badge.questionmark")
                        .font(.system(size: 54))
                        .foregroundColor(.batTextTertiary)
                    Text("[ NO CATEGORIES ]")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.batTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 50)
            } else {
                ForEach(dataManager.categories) { category in
                    CategoryRow(category: category) {
                        editingCategory = category
                    }
                }
            }
        }
    }

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("[ TAG DATABASE ]")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.batTextPrimary)
                    .tracking(2)
                Spacer()
                Button(action: { showingAddTag = true }) {
                    Image(systemName: "plus.square.fill")
                        .foregroundColor(.batCyan)
                        .imageScale(.medium)
                        .batGlow(color: .batCyan, radius: 2)
                }
                .buttonStyle(.plain)
            }

            if dataManager.tags.isEmpty {
                VStack(spacing: 14) {
                    Image(systemName: "tag.slash")
                        .font(.system(size: 54))
                        .foregroundColor(.batTextTertiary)
                    Text("[ NO TAGS ]")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.batTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 50)
            } else {
                ForEach(dataManager.tags) { tag in
                    TagRow(tag: tag) {
                        editingTag = tag
                    }
                }
            }
        }
    }
}

struct CategoryRow: View {
    let category: Category
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Rectangle()
                    .fill(category.displayColor)
                    .frame(width: 8, height: 8)

                Text(category.name.uppercased())
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.batTextPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 10))
                    .foregroundColor(.batCyan)
            }
            .padding(10)
            .background(Color.batDarkGray)
            .overlay(
                Rectangle()
                    .strokeBorder(Color.batMidGray.opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct TagRow: View {
    let tag: Tag
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Rectangle()
                    .fill(tag.displayColor)
                    .frame(width: 8, height: 8)

                Text(tag.name.uppercased())
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.batTextPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 10))
                    .foregroundColor(.batCyan)
            }
            .padding(10)
            .background(Color.batDarkGray)
            .overlay(
                Rectangle()
                    .strokeBorder(Color.batMidGray.opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct CategoryEditView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var dataManager = DataManager.shared

    let category: Category?
    @State private var name: String
    @State private var color: Color
    @State private var showingDeleteAlert = false

    init(category: Category?) {
        self.category = category
        _name = State(initialValue: category?.name ?? "")
        _color = State(initialValue: category?.displayColor ?? .blue)
    }

    var isValid: Bool {
        !name.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header - Batman style
            HStack {
                Image(systemName: category == nil ? "folder.badge.plus" : "pencil.line")
                    .foregroundColor(.batCyan)
                    .batGlow(color: .batCyan, radius: 2)

                Text(category == nil ? "[ NEW CATEGORY ]" : "[ EDIT CATEGORY ]")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
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

            // Form
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("[ NAME ]")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.batTextTertiary)
                        .tracking(1)
                    TextField("CATEGORY NAME", text: $name)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.batTextPrimary)
                        .padding(10)
                        .background(Color.batDarkGray)
                        .overlay(
                            Rectangle()
                                .strokeBorder(Color.batMidGray.opacity(0.5), lineWidth: 1)
                        )
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("[ COLOR ]")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.batTextTertiary)
                        .tracking(1)
                    ColorPicker("", selection: $color)
                        .labelsHidden()
                        .padding(10)
                        .background(Color.batDarkGray)
                        .overlay(
                            Rectangle()
                                .strokeBorder(Color.batMidGray.opacity(0.5), lineWidth: 1)
                        )
                }
            }
            .padding(14)
            .background(Color.batBlack)

            Rectangle()
                .fill(Color.batCyan.opacity(0.3))
                .frame(height: 1)

            // Footer
            HStack(spacing: 12) {
                if category != nil {
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

                Button(action: { saveCategory() }) {
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
        .frame(width: 350, height: 280)
        .background(Color.batBlack)
        .alert("Delete Category", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let category = category {
                    dataManager.deleteCategory(category)
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete this category?")
        }
    }

    private func saveCategory() {
        let hexColor = color.toHex() ?? "#007AFF"

        if let existing = category {
            let updated = Category(id: existing.id, name: name, color: hexColor)
            dataManager.updateCategory(updated)
        } else {
            let new = Category(name: name, color: hexColor)
            dataManager.addCategory(new)
        }

        dismiss()
    }
}

struct TagEditView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var dataManager = DataManager.shared

    let tag: Tag?
    @State private var name: String
    @State private var color: Color
    @State private var showingDeleteAlert = false

    init(tag: Tag?) {
        self.tag = tag
        _name = State(initialValue: tag?.name ?? "")
        _color = State(initialValue: tag?.displayColor ?? .blue)
    }

    var isValid: Bool {
        !name.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header - Batman style
            HStack {
                Image(systemName: tag == nil ? "tag.fill" : "pencil.line")
                    .foregroundColor(.batCyan)
                    .batGlow(color: .batCyan, radius: 2)

                Text(tag == nil ? "[ NEW TAG ]" : "[ EDIT TAG ]")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
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

            // Form
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("[ NAME ]")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.batTextTertiary)
                        .tracking(1)
                    TextField("TAG NAME", text: $name)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.batTextPrimary)
                        .padding(10)
                        .background(Color.batDarkGray)
                        .overlay(
                            Rectangle()
                                .strokeBorder(Color.batMidGray.opacity(0.5), lineWidth: 1)
                        )
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("[ COLOR ]")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.batTextTertiary)
                        .tracking(1)
                    ColorPicker("", selection: $color)
                        .labelsHidden()
                        .padding(10)
                        .background(Color.batDarkGray)
                        .overlay(
                            Rectangle()
                                .strokeBorder(Color.batMidGray.opacity(0.5), lineWidth: 1)
                        )
                }
            }
            .padding(14)
            .background(Color.batBlack)

            Rectangle()
                .fill(Color.batCyan.opacity(0.3))
                .frame(height: 1)

            // Footer
            HStack(spacing: 12) {
                if tag != nil {
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

                Button(action: { saveTag() }) {
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
        .frame(width: 350, height: 280)
        .background(Color.batBlack)
        .alert("Delete Tag", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let tag = tag {
                    dataManager.deleteTag(tag)
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete this tag?")
        }
    }

    private func saveTag() {
        let hexColor = color.toHex() ?? "#007AFF"

        if let existing = tag {
            let updated = Tag(id: existing.id, name: name, color: hexColor)
            dataManager.updateTag(updated)
        } else {
            let new = Tag(name: name, color: hexColor)
            dataManager.addTag(new)
        }

        dismiss()
    }
}
