import Foundation
import IndexStoreDB
import TSCBasic

public final class Analyzer {
    
    private let sourceCodeCollector: SourceCollector
    private let sourceKitserver: SourceKitServer
    private let workSpace: Workspace
    private let configuration: Configuration
    private var xmlRule: XMLRule?
    private var xmlServer: XMLServer?
    
    public init(configuration: Configuration) throws {
        sourceCodeCollector = SourceCollector(rootPath: configuration.projectPath,
                                              configuration: configuration)
        self.configuration = configuration
        let buildSystem = DatabaseBuildSystem(indexStorePath: configuration.indexStorePath,
                                              indexDatabasePath: configuration.indexDatabasePath)
        workSpace = try Workspace(buildSettings: buildSystem)
        workSpace.index?.pollForUnitChangesAndWait()
        sourceKitserver = SourceKitServer(workspace: workSpace)
        
        let xmlRules = configuration.rules.lazy.compactMap{ $0 as? XMLRule }
        if let xmlRule = xmlRules.first {
            let xmlServer = XMLServer(rootPath: configuration.projectPath,
                                      configuration: configuration)
            self.xmlServer = xmlServer
            self.xmlServer?.bootstrap()
            xmlRule.server = xmlServer
            self.xmlRule = xmlRule
        }
    }
    
    public func analyze() throws -> [SourceDetail] {
        var deadSources: [SourceDetail] = []
        try sourceCodeCollector.collect()
        
        for source in sourceCodeCollector.sources {
            if !analyze(source: source) {
                deadSources.append(source)
            }
        }
        return deadSources
    }
}

extension Analyzer {
    
    /// Detect  whether source code if used
    /// - Parameter source: The source code to detect.
    private func analyze(source: SourceDetail) -> Bool {
        let symbols = sourceKitserver.findWorkspaceSymbols(matching: source.name)

        // If not find symobol of source, means source used.
        guard let symbol = symbols.unique(of: source) else {
            return true
        }

        // Skip declarations that override another. This works for both subclass overrides &
        // protocol extension overrides.
        let overrided = symbols.lazy.filter{ $0.symbol.usr != symbol.symbol.usr }.contains(where: { $0.isOverride(of: symbol) })
        if overrided {
            return true
        }

        if symbol.roles.contains(.overrideOf) {
            return true
        }
        
        let symbolOccurenceResults = sourceKitserver.occurrences(
            ofUSR: symbol.symbol.usr,
            roles: [.reference],
            workspace: workSpace)
        
        // Skip extensions, the extension of class, struct, etc, don't means refenced.
        if filterExtension(source: source, symbols: symbolOccurenceResults).count > 0 {
            return true
        }
        
        // XMLRule anzlyze
        if let xmlRule = self.xmlRule, xmlRule.analyze(source) {
            return true
        }
                
        return false
    }
    
    /// In the rule class, struct, enum and protocol extensions  are not mean  used,
    /// But in symbol their extensions are defined as refered,
    /// So we need to fitler their extensions.
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
