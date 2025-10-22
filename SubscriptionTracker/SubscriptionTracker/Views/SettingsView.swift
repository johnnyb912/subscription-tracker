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
            // Section selector
            HStack(spacing: 0) {
                Button(action: { selectedSection = .categories }) {
                    Text("Categories")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedSection == .categories ? Color.accentColor.opacity(0.1) : Color.clear)
                        .foregroundColor(selectedSection == .categories ? .accentColor : .gray)
                }
                .buttonStyle(.plain)

                Button(action: { selectedSection = .tags }) {
                    Text("Tags")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedSection == .tags ? Color.accentColor.opacity(0.1) : Color.clear)
                        .foregroundColor(selectedSection == .tags ? .accentColor : .gray)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))

            Divider()

            // Content
            ScrollView {
                VStack(spacing: 16) {
                    if selectedSection == .categories {
                        categoriesSection
                    } else {
                        tagsSection
                    }
                }
                .padding()
            }
        }
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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Manage Categories")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Button(action: { showingAddCategory = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
            }

            if dataManager.categories.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "folder")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("No categories yet")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Manage Tags")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Button(action: { showingAddTag = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
            }

            if dataManager.tags.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tag")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("No tags yet")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
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
            HStack(spacing: 12) {
                Circle()
                    .fill(category.displayColor)
                    .frame(width: 20, height: 20)

                Text(category.name)
                    .font(.system(size: 13))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

struct TagRow: View {
    let tag: Tag
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Circle()
                    .fill(tag.displayColor)
                    .frame(width: 20, height: 20)

                Text(tag.name)
                    .font(.system(size: 13))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
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
        VStack(spacing: 16) {
            Text(category == nil ? "New Category" : "Edit Category")
                .font(.system(size: 16, weight: .semibold))

            VStack(alignment: .leading, spacing: 6) {
                Text("Name")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                TextField("Category name", text: $name)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Color")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                ColorPicker("", selection: $color)
                    .labelsHidden()
            }

            HStack(spacing: 12) {
                if category != nil {
                    Button("Delete") {
                        showingDeleteAlert = true
                    }
                    .foregroundColor(.red)
                }

                Spacer()

                Button("Cancel") {
                    dismiss()
                }

                Button("Save") {
                    saveCategory()
                }
                .disabled(!isValid)
            }
        }
        .padding()
        .frame(width: 300)
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
        VStack(spacing: 16) {
            Text(tag == nil ? "New Tag" : "Edit Tag")
                .font(.system(size: 16, weight: .semibold))

            VStack(alignment: .leading, spacing: 6) {
                Text("Name")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                TextField("Tag name", text: $name)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Color")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                ColorPicker("", selection: $color)
                    .labelsHidden()
            }

            HStack(spacing: 12) {
                if tag != nil {
                    Button("Delete") {
                        showingDeleteAlert = true
                    }
                    .foregroundColor(.red)
                }

                Spacer()

                Button("Cancel") {
                    dismiss()
                }

                Button("Save") {
                    saveTag()
                }
                .disabled(!isValid)
            }
        }
        .padding()
        .frame(width: 300)
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
