import SwiftUI

@main
struct ClipApp: App {

    // MARK: - Properties

    @StateObject private var appState = AppState()

    // MARK: - Body

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(appState)
        } label: {
            HStack(spacing: 3) {
                Image(systemName: "paperclip")
                    .font(.system(size: 12))

                Text("\(appState.itemCount)")
                    .font(.system(size: 10, design: .monospaced))
            }
        }
        .menuBarExtraStyle(.window)
    }
}

// MARK: - App State

/// Main application state managing clipboard monitoring and history.
@MainActor
final class AppState: ObservableObject {

    // MARK: - Published Properties

    @Published var items: [ClipItem] = []
    @Published var searchText = ""
    @Published var selectedItemID: UUID?
    @Published var copiedNotification = false

    // MARK: - Services

    let clipboardService = ClipboardService()

    // MARK: - Private

    private var pollTask: Task<Void, Never>?

    // MARK: - Computed Properties

    var itemCount: Int { items.count }

    var filteredItems: [ClipItem] {
        guard !searchText.isEmpty else { return items }
        let lowered = searchText.lowercased()
        return items.filter { $0.matches(lowered) }
    }

    var pinnedCount: Int {
        items.filter { $0.isPinned }.count
    }

    // MARK: - Initializers

    init() {
        startMonitoring()
    }

    deinit {
        pollTask?.cancel()
    }

    // MARK: - Public Methods

    func copyItem(_ item: ClipItem) {
        Task {
            await clipboardService.copyToClipboard(item)
            copiedNotification = true
            try? await Task.sleep(for: .seconds(1.5))
            copiedNotification = false
        }
    }

    func togglePin(_ id: UUID) {
        Task {
            await clipboardService.togglePin(id)
            items = await clipboardService.items
        }
    }

    func removeItem(_ id: UUID) {
        Task {
            await clipboardService.removeItem(id)
            items = await clipboardService.items
        }
    }

    func clearHistory() {
        Task {
            await clipboardService.clearUnpinned()
            items = await clipboardService.items
        }
    }

    func clearAll() {
        Task {
            await clipboardService.clearAll()
            items = await clipboardService.items
        }
    }

    // MARK: - Private Methods

    private func startMonitoring() {
        pollTask = Task { [weak self] in
            guard let self = self else { return }

            // Sync so we don't capture whatever is already on the clipboard.
            await self.clipboardService.syncChangeCount()

            while !Task.isCancelled {
                let newItem = await self.clipboardService.checkForChanges()
                if newItem != nil {
                    let currentItems = await self.clipboardService.items
                    await MainActor.run {
                        self.items = currentItems
                    }
                }
                try? await Task.sleep(for: .seconds(ClipboardService.pollInterval))
            }
        }
    }
}
