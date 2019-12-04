import Foundation

/// The kind of source code, we only check the follow kind
public enum SourceKind {
    case `class`
    case `struct`
    
    /// Contains function, instantsMethod, classMethod, staticMethod
    case function
    case `enum`
    case `protocol`
    case `typealias`
    case `operator`
    case `extension`
}

public struct SourceDetail {
    
    /// The name of the source, if any.
    public var name: String
    
    /// The kind of the source
    public var sourceKind: SourceKind
    
    /// The location of the source
    public var location: SourceLocation
}

extension SourceDetail: CustomStringConvertible {
    public var description: String {
        "\(name) | \(sourceKind) | \(location.description)"
    }
}

extension SourceDetail: Equatable {
    public static func == (lhs: SourceDetail, rhs: SourceDetail) -> Bool {
        lhs.name == rhs.name && lhs.location == rhs.location
    }
}

extension SourceDetail {
    var needFilterExtension: Bool {
        return sourceKind == .class ||
            sourceKind == .struct ||
            sourceKind == .enum ||
            sourceKind == .protocol
    }
}
