import Foundation
import SwiftSyntax

public typealias SSSourceLocation = SwiftSyntax.SourceLocation

public struct SourceLocation {
    public let path: String
    public let line: Int
    public let column: Int
    public let offset: Int
}

extension SourceLocation: CustomStringConvertible {
    public var description: String {
        "\(path):\(line):\(column)"
    }
}

extension SourceLocation: Equatable {
    public static func == (lhs: SourceLocation, rhs: SourceLocation) -> Bool {
        lhs.path == rhs.path && lhs.line == rhs.line && lhs.column == rhs.column
    }
}

extension SourceLocation {
    /// Converts a `SourceLocation` to a `SwiftSyntax.SourceLocation`.
    public var ssLocation: SSSourceLocation {
        return SSSourceLocation(
            line: line,
            column: column,
            offset: offset,
            file: path)
    }
}
