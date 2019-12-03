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
