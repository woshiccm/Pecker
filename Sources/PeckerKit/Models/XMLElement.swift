import Foundation

struct XMLElement {
    let name: String
    let kind: XMLElementKind
    let module: String?
}

extension XMLElement: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(kind)
        hasher.combine(module)
    }
    
    public static func == (lhs: XMLElement, rhs: XMLElement) -> Bool {
        return (lhs.name == rhs.name) && (lhs.kind == rhs.kind) && (lhs.module == rhs.module)
    }
}
