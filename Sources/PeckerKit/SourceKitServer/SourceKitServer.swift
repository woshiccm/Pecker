import Foundation
import IndexStoreDB

public class SourceKitServer {
    
    public var workspace: Workspace?
    
    public init(workspace: Workspace? = nil) {
        self.workspace = workspace
    }
    
    public func findWorkspaceSymbols(matching: String) -> [SymbolOccurrence] {
        var symbolOccurenceResults: [SymbolOccurrence] = []
        workspace?.index?.pollForUnitChangesAndWait()
        workspace?.index?.forEachCanonicalSymbolOccurrence(
          containing: matching,
          anchorStart: false,
          anchorEnd: false,
          subsequence: true,
          ignoreCase: true
        ) { symbol in
            if !symbol.location.isSystem &&
                !symbol.roles.contains(.accessorOf) &&
                !symbol.roles.contains(.overrideOf) &&
                symbol.roles.contains(.definition) {
            symbolOccurenceResults.append(symbol)
          }
          return true
        }
        return symbolOccurenceResults
    }
    
    public func occurrences(ofUSR usr: String, roles: SymbolRole, workspace: Workspace) -> [SymbolOccurrence] {
        guard let index = workspace.index else {
            return []
        }
        return index.occurrences(ofUSR: usr, roles: roles)
    }
}
