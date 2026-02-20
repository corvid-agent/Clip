import SwiftUI

/// Empty state displayed when there are no clipboard items.
struct EmptyStateView: View {

    // MARK: - Properties

    let hasSearch: Bool

    // MARK: - Body

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: hasSearch ? "magnifyingglass" : "paperclip")
                .font(.title2)
                .foregroundStyle(.tertiary)

            Text(hasSearch ? "no matches" : "clipboard empty")
                .font(Theme.mono)
                .foregroundStyle(.secondary)

            if !hasSearch {
                Text("copy something to get started")
                    .font(Theme.monoSmall)
                    .foregroundStyle(.quaternary)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
    }
}
