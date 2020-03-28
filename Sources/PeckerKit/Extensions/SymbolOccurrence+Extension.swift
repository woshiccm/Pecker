import Foundation
import IndexStoreDB

extension SymbolOccurrence {
    
    /// Whether symbol is class, struct, enum, protocol extensions
    /// - Parameter sources: All the source extensions
    func isSourceExtension(safeSources: SafeSourceExtensions) -> Bool {
        guard safeSources.value[self.identifier] != nil else {
            return false
        }
        safeSources.atomically { $0[self.identifier] = nil }
        return true
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
