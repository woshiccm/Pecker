import Foundation
import IndexStoreDB

extension Array where Element == SymbolOccurrence {
    
    /// Find the unique symbol of source in the array
    /// - Parameter source: SourceDetail
    func unique(of source: SourceDetail) -> Element? {
        return self.first(where: { isEqual(source: source, symbol: $0) })
    }
}

/// Whether symbol is unique of source
/// - Parameters:
///   - source: SourceDetail
///   - symbol: SymbolOccurrence
func isEqual(source: SourceDetail, symbol: SymbolOccurrence) -> Bool {
    return source.identifier == symbol.identifier
}
