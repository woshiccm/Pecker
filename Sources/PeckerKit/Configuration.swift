import Foundation
import TSCBasic

/// Holds the complete set of configured values and defaults.
public struct Configuration {
    
    private static let fileName = ".pecker.yml"
    
    public let rules: [Rule]
    
    public let reporter: Reporter
    
    public let included: [AbsolutePath]
    
    public let excluded: [AbsolutePath]
    
    public let excludedGroupName: [String]
    
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
                  rules: [Rule],
                  reporter: Reporter,
                  included: [AbsolutePath],
                  excluded: [AbsolutePath],
                  excludedGroupName: [String],
                  blacklistFiles: [String],
                  blacklistSymbols: [String],
                  outputFile: AbsolutePath) {
        self.projectPath = projectPath
        self.indexStorePath = indexStorePath
        self.indexDatabasePath = NSTemporaryDirectory() + "index_\(getpid())"
        self.rules = rules
        self.reporter = reporter
        self.included = included
        self.excluded = excluded
        self.excludedGroupName = excludedGroupName
        self.blacklistFiles = blacklistFiles
        self.blacklistSymbols = blacklistSymbols
        self.outputFile = outputFile
    }
    
    public init(projectPath: AbsolutePath, indexStorePath: String = "", configPath: AbsolutePath) {
        var yamlConfiguration: YamlConfiguration?
        do {
            let yamlContents = try String(contentsOfFile: configPath.asURL.path, encoding: .utf8)
            yamlConfiguration = try YamlParser.parse(yamlContents)
        } catch YamlParserError.yamlParsing(let message) {
            log(message)
        } catch {
            log(error.localizedDescription)
        }
        
        let reporter = ReporterFactory.make(yamlConfiguration?.reporter)
        RuleFactory.yamlConfiguration = yamlConfiguration
        let rules = RuleFactory.make()
        let outputFilePath = createOutputFilePath(projectPath: projectPath, outputFile: yamlConfiguration?.outputFile)
        
        let included = (yamlConfiguration?.included ?? [""]).map {
            return AbsolutePath($0, relativeTo: projectPath)
        }.filter { localFileSystem.exists($0) }
        
        let excluded = (yamlConfiguration?.excluded ?? []).map {
            return AbsolutePath($0, relativeTo: projectPath)
        }.filter { localFileSystem.exists($0) }
        
        self.init(projectPath: projectPath,
                  indexStorePath: indexStorePath,
                  rules: rules,
                  reporter: reporter,
                  included: included,
                  excluded: excluded ,
                  excludedGroupName: yamlConfiguration?.excludedGroupName ?? [],
                  blacklistFiles: yamlConfiguration?.blacklistFiles ?? [],
                  blacklistSymbols: yamlConfiguration?.blacklistSymbols ?? [],
                  outputFile: outputFilePath)
    }
}

private func createOutputFilePath(projectPath: AbsolutePath, outputFile: String?) -> AbsolutePath {
    if let outputFile = outputFile {
        if let _ = try? RelativePath(validating: outputFile) {
            let outputFilePath = AbsolutePath(outputFile, relativeTo: projectPath)
            if let pathExtension = outputFilePath.extension {
                if pathExtension == "json" && localFileSystem.exists(outputFilePath.parentDirectory) {
                    return outputFilePath
                }
            }
        } else if let absolutePath = try? AbsolutePath(validating: outputFile) {
            if let pathExtension = absolutePath.extension {
                if pathExtension == "json" && localFileSystem.exists(absolutePath.parentDirectory) {
                    return absolutePath
                }
            }
        }
    }
    return projectPath.appending(component: "pecker.result.json")
}
