import SwiftUI

/// A single row in the clipboard history list.
struct ClipItemRow: View {

    // MARK: - Properties

    let item: ClipItem
    let isHovered: Bool
    let onCopy: () -> Void
    let onTogglePin: () -> Void
    let onDelete: () -> Void

    // MARK: - Body

    var body: some View {
        HStack(spacing: 8) {
            // Pin indicator
            if item.isPinned {
                Image(systemName: "pin.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(Theme.pinned)
                    .frame(width: 12)
            } else {
                Color.clear.frame(width: 12)
            }

            // Type icon
            Image(systemName: item.iconName)
                .font(.system(size: 10))
                .foregroundStyle(iconColor)
                .frame(width: 14)

            // Content preview
            VStack(alignment: .leading, spacing: 1) {
                Text(item.preview)
                    .font(Theme.monoSmall)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text(item.relativeTime)
                    .font(Theme.monoTiny)
                    .foregroundStyle(.quaternary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Type badge
            Text(item.typeLabel)
                .font(.system(size: 8, design: .monospaced))
                .foregroundStyle(.quaternary)
                .frame(width: 32, alignment: .trailing)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(isHovered ? Color.primary.opacity(0.05) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture { onCopy() }
        .contextMenu {
            Button("Copy") { onCopy() }
            Divider()
            Button(item.isPinned ? "Unpin" : "Pin") { onTogglePin() }
            Button("Delete") { onDelete() }
        }
    }

    // MARK: - Private

    private var iconColor: Color {
        switch item.content {
        case .text: return .secondary
        case .url: return Theme.link
        case .image: return Theme.accent
        }
    }
}
