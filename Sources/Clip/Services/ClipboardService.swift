@preconcurrency import Foundation
import AppKit

/// Actor responsible for monitoring the system clipboard and managing history.
public actor ClipboardService {

    // MARK: - Constants

    /// Maximum number of items to retain in history.
    public static let maxItems = 50

    /// Polling interval in seconds.
    public static let pollInterval: TimeInterval = 0.5

    // MARK: - State

    /// All clipboard items, ordered with pinned first then by timestamp descending.
    public private(set) var items: [ClipItem] = []

    /// The last observed pasteboard change count.
    private var lastChangeCount: Int = 0

    // MARK: - Initializers

    public init() {}

    // MARK: - Public Methods

    /// Checks the pasteboard for changes and captures new content if found.
    /// Returns the new item if one was captured, nil otherwise.
    @discardableResult
    public func checkForChanges() -> ClipItem? {
        let pasteboard = NSPasteboard.general
        let currentCount = pasteboard.changeCount

        guard currentCount != lastChangeCount else { return nil }
        lastChangeCount = currentCount

        guard let item = captureCurrentContent(from: pasteboard) else { return nil }

        // Deduplicate: remove existing item with same content (unless pinned).
        items.removeAll { $0.content == item.content && !$0.isPinned }

        items.insert(item, at: pinnedCount)

        trimHistory()
        return item
    }

    /// Copies an item back to the system clipboard.
    public func copyToClipboard(_ item: ClipItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        switch item.content {
        case .text(let string):
            pasteboard.setString(string, forType: .string)
        case .url(let url):
            pasteboard.setString(url.absoluteString, forType: .string)
        case .image(let data):
            pasteboard.setData(data, forType: .png)
        }

        // Update the change count so we don't re-capture our own paste.
        lastChangeCount = pasteboard.changeCount
    }

    /// Toggles the pinned state of an item.
    public func togglePin(_ id: UUID) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }

        items[index].isPinned.toggle()
        sortItems()
    }

    /// Removes a single item from history.
    public func removeItem(_ id: UUID) {
        items.removeAll { $0.id == id }
    }

    /// Clears all unpinned items from history.
    public func clearUnpinned() {
        items.removeAll { !$0.isPinned }
    }

    /// Clears all items from history including pinned.
    public func clearAll() {
        items.removeAll()
    }

    /// Returns items filtered by search query.
    public func filteredItems(query: String) -> [ClipItem] {
        guard !query.isEmpty else { return items }
        return items.filter { $0.matches(query) }
    }

    /// Adds an item directly (used for testing).
    public func addItem(_ item: ClipItem) {
        items.insert(item, at: pinnedCount)
        trimHistory()
    }

    /// Syncs the last change count with the current pasteboard (used at startup).
    public func syncChangeCount() {
        lastChangeCount = NSPasteboard.general.changeCount
    }

    // MARK: - Private Methods

    /// Number of pinned items at the front of the list.
    private var pinnedCount: Int {
        items.prefix(while: { $0.isPinned }).count
    }

    /// Captures the current pasteboard content as a ClipItem.
    private func captureCurrentContent(from pasteboard: NSPasteboard) -> ClipItem? {
        // Try URL first (check if string looks like a URL).
        if let string = pasteboard.string(forType: .string) {
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)

            if let url = URL(string: trimmed),
               let scheme = url.scheme,
               ["http", "https", "ftp", "ssh"].contains(scheme.lowercased()),
               url.host != nil {
                return ClipItem(content: .url(url))
            }

            if !trimmed.isEmpty {
                return ClipItem(content: .text(string))
            }
        }

        // Try image (PNG or TIFF data).
        if let data = pasteboard.data(forType: .png) {
            return ClipItem(content: .image(data))
        }

        if let data = pasteboard.data(forType: .tiff) {
            return ClipItem(content: .image(data))
        }

        return nil
    }

    /// Sorts items: pinned first (by timestamp desc), then unpinned by timestamp desc.
    private func sortItems() {
        items.sort { a, b in
            if a.isPinned != b.isPinned { return a.isPinned }
            return a.timestamp > b.timestamp
        }
    }

    /// Trims history to the maximum item count, preserving pinned items.
    private func trimHistory() {
        while items.count > Self.maxItems {
            // Remove the oldest unpinned item.
            if let lastUnpinnedIndex = items.lastIndex(where: { !$0.isPinned }) {
                items.remove(at: lastUnpinnedIndex)
            } else {
                // All pinned — remove the oldest pinned item.
                items.removeLast()
            }
        }
    }
}
