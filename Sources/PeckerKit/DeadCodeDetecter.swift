import Foundation
import Path
import IndexStoreDB
import TSCBasic

public final class DeadCodeDetecter {
    
    let sourceCodeCollector: SourceCollector
    let server: SourceKitServer
    let workSpace: Workspace
    
    public init(configuration: Configuration) throws {
        sourceCodeCollector = SourceCollector(path: configuration.projectPath)
        let buildSystem = DatabaseBuildSystem(indexStorePath: configuration.indexStorePath,
                                              indexDatabasePath: configuration.indexDatabasePath)
        workSpace = try Workspace(buildSettings: buildSystem)
        server = SourceKitServer(workspace: workSpace)
    }
    
    public func detect() throws -> [SourceDetail] {
        var deadSources: [SourceDetail] = []
        try sourceCodeCollector.collect()
        
        for source in sourceCodeCollector.sources {
            if detect(source: source) {
                deadSources.append(source)
            }
        }
        
        return deadSources
    }
}

extension DeadCodeDetecter {
    
    
    /// Detect  whether source code if used
    /// - Parameter source: The source code to detect
    private func detect(source: SourceDetail) -> Bool {
        guard let symbol = findSymbol(source: source) else {
            return false
        }
        
        if symbol.roles.contains(.overrideOf) {
            return false
        }
        
        let symbolOccurenceResults = server.occurrences(
            ofUSR: symbol.symbol.usr,
            roles: [.reference],
            workspace: workSpace)
        
        if filterExtension(source: source, symbols: symbolOccurenceResults).count > 0 {
            return false
        } else {
            return true
        }
    }
    
    /// Find source code symbol in the project index
    /// - Parameter source: The souece code
    private func findSymbol(source: SourceDetail) -> SymbolOccurrence? {
        let symbols = server.findWorkspaceSymbols(matching: source.name)
        for symbol in symbols {
            if isEqual(source: source, symbol: symbol) {
                return symbol
            }
        }
        return nil
    }
    
    
    /// In the rule class, struct, enum and protocol extensions  are not meant to be used,
    /// But in symbol their extensions are defined as refered
    /// So we need to fitler their extensions
    /// - Parameters:
    ///   - source: The source code, determine if need filter by source kind.
    ///   - symbols: All the source symbols
    private func filterExtension(source: SourceDetail, symbols: [SymbolOccurrence]) -> [SymbolOccurrence] {
        guard source.needFilterExtension else {
            return symbols
        }
        
        return symbols.lazy.filter { !$0.isSourceExtension(sources: &sourceCodeCollector.sourceExtensions) }
    }
}

func isEqual(source: SourceDetail, symbol: SymbolOccurrence) -> Bool {
    return source.location.path == symbol.location.path &&
        source.location.line == symbol.location.line &&
        source.location.column == symbol.location.utf8Column
}
