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
        workSpace.index?.pollForUnitChangesAndWait()
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
        let symbols = server.findWorkspaceSymbols(matching: source.name)

        // If not find symobol of source, means source used
        guard let symbol = symbols.unique(of: source) else {
            return false
        }

        // Whether source symbol is overrided by other symbols, true means source used
        let overrided = symbols.lazy.filter{ $0.symbol.usr != symbol.symbol.usr }.contains(where: { $0.isOverride(of: symbol) })
        if overrided {
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
