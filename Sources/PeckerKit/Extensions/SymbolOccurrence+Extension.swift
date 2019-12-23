import Foundation
import IndexStoreDB

extension SymbolOccurrence {
    
    /// Whether symbol is class, struct, enum, protocol extensions
    /// - Parameter sources: All the source extensions
    func isSourceExtension(sources: inout [String: SourceDetail]) -> Bool {
        if sources[self.identifier] != nil {
            sources[self.identifier] = nil
            return true
        }
        return false
    }
}

extension SymbolOccurrence {
    
    /// Whether  is override of giving symbol
    /// - Parameter symbol: giving symbol
    func isOverride(of symbol: SymbolOccurrence) -> Bool {
        relations.contains(where: { $0.roles.contains(.overrideOf) && $0.symbol.usr == symbol.symbol.usr})
    }
}

extension SymbolOccurrence {
    var identifier: String {
        return "\(location.path):\(location.line):\(location.utf8Column)"
    }
}
