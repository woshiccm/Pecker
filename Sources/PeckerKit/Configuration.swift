import Foundation
import TSCBasic

/// Holds the complete set of configured values and defaults.
public struct Configuration {
    
    private static let fileName = ".pecker.yml"
    
    public let rules: [Rule]
    
    public let reporter: Reporter
    
    public let included: [AbsolutePath]
    
    public let excluded: [AbsolutePath]
    
    public let blacklistFiles: [String]
    
    public let blacklistSymbols: [String]
    
    public let outputFile: AbsolutePath
    
    /// The  project path
    public let projectPath: AbsolutePath
    
    /// The project index storePath path
    public let indexStorePath: String
    
    /// The project index database path
    public var indexDatabasePath: String
    
    internal init(projectPath: AbsolutePath,
                  indexStorePath: String,
                  indexDatabasePath: String? = nil,
                  rules: [Rule],
                  reporter: Reporter,
                  included: [AbsolutePath],
                  excluded: [AbsolutePath],
                  blacklistFiles: [String],
                  blacklistSymbols: [String],
                  outputFile: AbsolutePath) {
        self.projectPath = projectPath
        self.indexStorePath = indexStorePath
        self.indexDatabasePath = indexDatabasePath ?? NSTemporaryDirectory() + "index_\(getpid())"
        self.rules = rules
        self.reporter = reporter
        self.included = included
        self.excluded = excluded
        self.blacklistFiles = blacklistFiles
        self.blacklistSymbols = blacklistSymbols
        self.outputFile = outputFile
    }
    
    public init(projectPath: AbsolutePath, indexStorePath: String = "", indexDatabasePath: String? = nil) {
        let fullPath = projectPath.appending(RelativePath(Configuration.fileName)).asURL.path
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
        let outputFilePath = AbsolutePath(yamlConfiguration?.outputFile ?? projectPath.asURL.path).appending(component: "pecker.result.json")
        self.init(projectPath: projectPath,
                  indexStorePath: indexStorePath,
                  indexDatabasePath: indexDatabasePath,
                  rules: rules,
                  reporter: reporter,
                  included: (yamlConfiguration?.included ?? [""]).map{ projectPath.appending(component: $0)},
                  excluded: (yamlConfiguration?.excluded ?? []).map{ projectPath.appending(component: $0)} ,
                  blacklistFiles: yamlConfiguration?.blacklistFiles ?? [],
                  blacklistSymbols: yamlConfiguration?.blacklistSymbols ?? [],
                  outputFile: outputFilePath)
    }
}
