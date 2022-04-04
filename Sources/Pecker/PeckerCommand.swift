import Foundation
import ArgumentParser
import TSCBasic
import PeckerKit

struct CommandLineOptions: ParsableArguments {
    
    /// The project path
    @Option(help: "Path of the project to detect")
    var path: String?
    
    /// The path to the index that should be loaded
    ///
    /// If not specified, the default is find from DerivedData with project name
    @Option(name: .shortAndLong, help: "Specify project index path [default: ~/Library/Developer/Xcode/DerivedData]")
    var indexStorePath: String?
    
    /// The configuration file path
    @Option(help: "The path of the configuration file")
    var config: String?
}

struct PeckerCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "Pecker",
      abstract: "Detect unused Swift and Objective-C code",
      version: "0.4.0"
    )

    @OptionGroup()
    var options: CommandLineOptions
    
    public init() {}
    
    public func run() throws {
        let configuration = try createConfiguration(options: options)

        let analyzer = try Analyzer(configuration: configuration)
        let unusedSources = try analyzer.analyze()
        configuration.reporter.report(configuration, sources: unusedSources)
    }
}

private func createConfiguration(options: CommandLineOptions) throws -> Configuration {
    let indexStorePath: AbsolutePath
    
    if let indexStorePathString = options.indexStorePath {
        indexStorePath = AbsolutePath(indexStorePathString)
    } else {
        let processInfo = ProcessInfo()
        // Find the index path, default is   ~Library/Developer/Xcode/DerivedData/<target>/Index/DataStore
        let buildRoot = try processInfo.environmentVariable(name: EnvironmentKeys.buildRoot)
        let buildRootPath = AbsolutePath(buildRoot)
        indexStorePath = buildRootPath.parentDirectory.parentDirectory.appending(component: "Index/DataStore")
    }
    
    guard let cwd = localFileSystem.currentWorkingDirectory else {
        throw PEError.fiendCurrentWorkingDirectoryFailed
    }
    let rootPath = AbsolutePath(options.path ?? "", relativeTo: cwd)
    let configPath = try createConfigurationPath(rootPath: rootPath, config: options.config)
    let configuration = Configuration(projectPath: rootPath, indexStorePath: indexStorePath.asURL.path, configPath: configPath)

    return configuration
}

private func createConfigurationPath(rootPath: AbsolutePath, config: String? = nil) throws -> AbsolutePath  {
    if let config = config {
        if let _ = try? RelativePath(validating: config) {
            let configPath = AbsolutePath(config, relativeTo: rootPath)
            if localFileSystem.exists(configPath) {
                return configPath
            }
        } else if let absolutePath = try? AbsolutePath(validating: config) {
            if localFileSystem.exists(absolutePath) {
                return absolutePath
            }
        }
        throw PEError.findConfigFaild(message: "The specified config path does not exist")
    } else {
        return rootPath.appending(RelativePath(".pecker.yml"))
    }
}

private extension ProcessInfo {
    func environmentVariable(name: String) throws -> String {
        guard let value = self.environment[name] else {
            throw ProcessError.missingValue(argument: name)
        }
    return value
  }
}

// Default values for non-optional Commander Options
struct EnvironmentKeys {
    static let bundleIdentifier = "PRODUCT_BUNDLE_IDENTIFIER"
    static let productModuleName = "PRODUCT_MODULE_NAME"
    static let scriptInputFileCount = "SCRIPT_INPUT_FILE_COUNT"
    static let scriptOutputFileCount = "SCRIPT_OUTPUT_FILE_COUNT"
    static let target = "TARGET_NAME"
    static let tempDir = "TEMP_DIR"
    static let xcodeproj = "PROJECT_FILE_PATH"
    static let buildRoot = "BUILD_ROOT"
}

enum ProcessError: Error {
    case missingValue(argument: String?)
}

enum PEError: Error {
    case findIndexFailed(message: String)
    case fiendCurrentWorkingDirectoryFailed
    case findProjectFileFailed(message: String)
    case indexStorePathPathWrong
    case findConfigFaild(message: String)
}
