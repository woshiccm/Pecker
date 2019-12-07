import Foundation
import Path
import TSCBasic

/// Holds the complete set of configured values and defaults.
public struct Configuration {
    
    private static let fileName = ".pecker.yml"
    
    public let rules: [Rule]
    
    public let reporter: Reporter
    
    public let included: [String]
    
    public let excluded: [String]
    
    public let blacklistFiles: [String]
    
    public let blacklistSymbols: [String]
    
    /// The  project path
    public let projectPath: Path
    
    /// The project index storePath path
    public let indexStorePath: String
    
    /// The project index database path
    public var indexDatabasePath: String
    
    internal init(projectPath: Path,
                  indexStorePath: String,
                  indexDatabasePath: String? = nil,
                  rules: [Rule],
                  reporter: Reporter,
                  included: [String],
                  excluded: [String],
                  blacklistFiles: [String],
                  blacklistSymbols: [String]) {
        self.projectPath = projectPath
        self.indexStorePath = indexStorePath
        self.indexDatabasePath = indexDatabasePath ?? NSTemporaryDirectory() + "index_\(getpid())"
        self.rules = rules
        self.reporter = reporter
        self.included = included
        self.excluded = excluded
        self.blacklistFiles = blacklistFiles
        self.blacklistSymbols = blacklistSymbols
    }
    
    public init(projectPath: Path, indexStorePath: String = "", indexDatabasePath: String? = nil) {
        let rootPath = AbsolutePath(projectPath.url.path)
        let fullPath = rootPath.appending(RelativePath(Configuration.fileName)).asURL.path
        var yamlConfiguration: YamlConfiguration?
        do {
            let yamlContents = try String(contentsOfFile: fullPath, encoding: .utf8)
            yamlConfiguration = try YamlParser.parse(yamlContents)
        } catch YamlParserError.yamlParsing(let message) {
            log(message)
        } catch {
            log(error.localizedDescription)
        }
        
        let reporter = ReporterFactory.make(yamlConfiguration?.reporter)
        let rules = RuleFactory.make(yamlConfiguration?.disabledRules)
        self.init(projectPath: projectPath,
                  indexStorePath: indexStorePath,
                  indexDatabasePath: indexDatabasePath,
                  rules: rules,
                  reporter: reporter,
                  included: yamlConfiguration?.included ?? [],
                  excluded: yamlConfiguration?.excluded ?? [],
                  blacklistFiles: yamlConfiguration?.blacklistFiles ?? [],
                  blacklistSymbols: yamlConfiguration?.blacklistSymbols ?? [])
    }
}
