import SwiftUI

/// Menu bar popup view displaying clipboard history.
struct MenuBarView: View {

    // MARK: - Properties

    @EnvironmentObject private var appState: AppState
    @FocusState private var isSearchFocused: Bool
    @State private var hoveredItemID: UUID?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView
            Divider().opacity(0.3)
            searchField
            Divider().opacity(0.3)
            contentView
            Divider().opacity(0.3)
            footerView
        }
        .frame(width: 380)
        .background(Color(nsColor: .windowBackgroundColor))
        .background { keyboardShortcuts }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 1) {
                Text("clip")
                    .font(.system(.title3, design: .monospaced, weight: .bold))
                    .foregroundStyle(Theme.accent)

                Text("\(appState.itemCount) items")
                    .font(Theme.monoSmall)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if appState.copiedNotification {
                Text("copied!")
                    .font(Theme.monoSmall)
                    .foregroundStyle(Theme.accent)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .animation(.easeInOut(duration: 0.2), value: appState.copiedNotification)
    }

    // MARK: - Search

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.caption)
                .foregroundStyle(Theme.accent)

            TextField("search...", text: $appState.searchText)
                .textFieldStyle(.plain)
                .font(Theme.mono)
                .focused($isSearchFocused)

            if !appState.searchText.isEmpty {
                Button(action: { appState.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    // MARK: - Content

    @ViewBuilder
    private var contentView: some View {
        if appState.filteredItems.isEmpty {
            EmptyStateView(hasSearch: !appState.searchText.isEmpty)
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(appState.filteredItems) { item in
                        ClipItemRow(
                            item: item,
                            isHovered: hoveredItemID == item.id,
                            onCopy: { appState.copyItem(item) },
                            onTogglePin: { appState.togglePin(item.id) },
                            onDelete: { appState.removeItem(item.id) }
                        )
                        .onHover { hoveredItemID = $0 ? item.id : nil }
                    }
                }
            }
            .frame(maxHeight: 340)
        }
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                if appState.pinnedCount > 0 {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(Theme.pinned)
                    Text("\(appState.pinnedCount)")
                        .font(Theme.monoTiny)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button(action: { appState.clearHistory() }) {
                Text("clear")
                    .font(Theme.monoSmall)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)

            Button(action: { NSApplication.shared.terminate(nil) }) {
                Text("quit")
                    .font(Theme.monoSmall)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Keyboard Shortcuts

    private var keyboardShortcuts: some View {
        VStack {
            Button("Search") { isSearchFocused = true }
                .keyboardShortcut("f", modifiers: .command)
            Button("Clear") { appState.clearHistory() }
                .keyboardShortcut("k", modifiers: .command)
            Button("Escape") {
                if !appState.searchText.isEmpty {
                    appState.searchText = ""
                }
            }
            .keyboardShortcut(.escape, modifiers: [])
        }
        .opacity(0)
        .allowsHitTesting(false)
    }
}
