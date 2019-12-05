import Foundation
import IndexStoreDB

extension SymbolOccurrence {
    
    /// Whether symbol is class, struct, enum, peotocol extensions
    /// - Parameter sources: All the source extensions
    func isSourceExtension(sources: inout [SourceDetail]) -> Bool {
        let result: Bool
        let filterSources = sources.filter { !isEqual(source: $0, symbol: self) }
        result = filterSources.count != sources.count
        if result {
            sources = filterSources
        }
        return result
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
