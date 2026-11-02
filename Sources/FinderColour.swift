import SwiftUI

enum FinderColour: Int, CaseIterable, Identifiable, Sendable {
    case none = 0
    case orange = 7
    case red = 6
    case yellow = 5
    case blue = 4
    case purple = 3
    case green = 2
    case grey = 1

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .none: "None"
        case .orange: "Orange"
        case .red: "Red"
        case .yellow: "Yellow"
        case .blue: "Blue"
        case .purple: "Purple"
        case .green: "Green"
        case .grey: "Grey"
        }
    }

    /// Finder's built-in tag is named "Gray" internally on standard macOS
    /// installations. The app presents the Canadian spelling "Grey".
    var finderTagName: String {
        self == .grey ? "Gray" : name
    }

    /// Finder stores the tag name and colour number together. Supplying both
    /// avoids ambiguity when a user has renamed or duplicated a built-in tag.
    var finderTagValue: String {
        "\(finderTagName)\n\(rawValue)"
    }

    var colour: Color {
        switch self {
        case .none: .clear
        case .orange: .orange
        case .red: .red
        case .yellow: .yellow
        case .blue: .blue
        case .purple: .purple
        case .green: .green
        case .grey: Color(nsColor: .systemGray)
        }
    }
}
