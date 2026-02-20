import Foundation

/// The type of content stored in a clipboard item.
public enum ClipContent: Sendable, Equatable {
    case text(String)
    case url(URL)
    case image(Data) // PNG data
}

/// A single clipboard history entry.
public struct ClipItem: Identifiable, Sendable, Equatable {

    // MARK: - Properties

    /// Unique identifier.
    public let id: UUID

    /// The clipboard content.
    public let content: ClipContent

    /// When the item was captured.
    public let timestamp: Date

    /// Whether this item is pinned to the top.
    public var isPinned: Bool

    // MARK: - Initializers

    public init(id: UUID = UUID(), content: ClipContent, timestamp: Date = Date(), isPinned: Bool = false) {
        self.id = id
        self.content = content
        self.timestamp = timestamp
        self.isPinned = isPinned
    }

    // MARK: - Display Helpers

    /// Short preview text for display in the list.
    public var preview: String {
        switch content {
        case .text(let string):
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.count > 80 {
                return String(trimmed.prefix(80)) + "..."
            }
            return trimmed
        case .url(let url):
            return url.absoluteString
        case .image(let data):
            let kb = data.count / 1024
            return "Image (\(kb) KB)"
        }
    }

    /// System image name for the item type icon.
    public var iconName: String {
        switch content {
        case .text: return "doc.text"
        case .url: return "link"
        case .image: return "photo"
        }
    }

    /// Short label describing the content type.
    public var typeLabel: String {
        switch content {
        case .text: return "text"
        case .url: return "url"
        case .image: return "image"
        }
    }

    /// Formatted relative timestamp string.
    public var relativeTime: String {
        let interval = Date().timeIntervalSince(timestamp)
        if interval < 5 { return "now" }
        if interval < 60 { return "\(Int(interval))s ago" }
        if interval < 3600 { return "\(Int(interval / 60))m ago" }
        if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        return "\(Int(interval / 86400))d ago"
    }

    /// Whether this item matches a search query.
    public func matches(_ query: String) -> Bool {
        let lowered = query.lowercased()
        switch content {
        case .text(let string):
            return string.lowercased().contains(lowered)
        case .url(let url):
            return url.absoluteString.lowercased().contains(lowered)
        case .image:
            return "image".contains(lowered)
        }
    }
}
