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
        let deadSources = ThreadSafe<[SourceDetail]>([])
        sourceCodeCollector.collect()

        DispatchQueue.concurrentPerform(iterations: sourceCodeCollector.sources.count) { (index) in
            if !analyze(source: sourceCodeCollector.sources[index]) {
                deadSources.atomically {
                    $0.append(sourceCodeCollector.sources[index])
                }
            }
        }

        return deadSources.value
    }
}

extension Analyzer {
    
    /// Detect  whether source code if used
    /// - Parameter source: The source code to detect.
    private func analyze(source: SourceDetail) -> Bool {
        // XMLRule analyze
        if let xmlRule = self.xmlRule, xmlRule.analyze(source) {
            return true
        }
        
        let symbols = sourceKitserver.findWorkspaceSymbols(matching: source.name)

        // If not find symbol of source, means source used.
        guard let symbol = symbols.unique(of: source) else {
            return true
        }

        // Skip declarations that override another. This works for both subclass overrides &
        // protocol extension overrides.
        let overridden = symbols.lazy.filter{ $0.symbol.usr != symbol.symbol.usr }.contains(where: { $0.isOverride(of: symbol) })
        if overridden {
            return true
        }

        if symbol.roles.contains(.overrideOf) {
            return true
        }
        
        let symbolOccurrenceResults = sourceKitserver.occurrences(
            ofUSR: symbol.symbol.usr,
            roles: [.reference],
            workspace: workSpace)
        
        // Skip extensions, the extension of class, struct, etc, don't means referenced.
        if filterExtension(source: source, symbols: symbolOccurrenceResults).count > 0 {
            return true
        }
        
        //Handle the follow case
        /*
         public protocol TestProtocol {
             func test()
         }

         class TestObject: TestProtocol {}

         extension TestObject {
             func test() {}
         }
         */
        if source.sourceKind == .function {
            let symbolOverrideOfOccurrences = sourceKitserver.occurrences(
                ofUSR: symbol.symbol.usr,
                roles: [.overrideOf],
                workspace: workSpace)
            
            if symbolOverrideOfOccurrences.contains(where: { $0.relations.lazy.filter{ $0.roles.contains(.overrideOf) }.count > 0}) {
                return true
            }
            
            let related = symbols.filter {
                $0.symbol.name == symbol.symbol.name &&
                    $0.symbol.usr != symbol.symbol.usr &&
                    ($0.symbol.kind == .classMethod || $0.symbol.kind == .instanceMethod || $0.symbol.kind == .staticMethod)
            }

            for re in related {
                let symbolOccurrenceResults = sourceKitserver.occurrences(
                    ofUSR: re.symbol.usr,
                    roles: [.overrideOf],
                    workspace: workSpace)
                if symbolOccurrenceResults.contains(where: { $0.relations.lazy.filter{ $0.roles.contains(.overrideOf)}.first(where: { $0.symbol.usr == symbol.symbol.usr }) != nil }) {
                    return true
                }
            }
        }
                
        return false
    }
    
    /// In the rule class, struct, enum and protocol extensions  are not mean  used,
    /// But in symbol their extensions are defined as referred,
    /// So we need to filter their extensions.
    /// - Parameters:
    ///   - source: The source code, determine if need filter by source kind.
    ///   - symbols: All the source symbols
    private func filterExtension(source: SourceDetail, symbols: [SymbolOccurrence]) -> [SymbolOccurrence] {
        guard source.needFilterExtension else {
            return symbols
        }
        return symbols.lazy.filter { !$0.isSourceExtension(safeSources: sourceCodeCollector.sourceExtensions) }
    }
}
