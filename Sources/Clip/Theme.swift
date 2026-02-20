import SwiftUI

/// Shared theme constants for the app.
public enum Theme {

    // MARK: - Colors

    /// Primary accent color used throughout the app.
    public static let accent = Color(red: 0.4, green: 0.9, blue: 0.6)

    /// Pinned item highlight color.
    public static let pinned = Color(red: 1.0, green: 0.8, blue: 0.3)

    /// URL item color.
    public static let link = Color(red: 0.3, green: 0.7, blue: 1.0)

    // MARK: - Fonts

    /// Monospaced body font.
    public static let mono = Font.system(.body, design: .monospaced)

    /// Monospaced caption font.
    public static let monoSmall = Font.system(.caption, design: .monospaced)

    /// Monospaced caption2 font.
    public static let monoTiny = Font.system(.caption2, design: .monospaced)
}
