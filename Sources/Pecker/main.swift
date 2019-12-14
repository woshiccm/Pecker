import Foundation
import PeckerKit
import TSCUtility
import TSCBasic

fileprivate func main(_ arguments: [String]) -> Int32 {
    let url = URL(fileURLWithPath: arguments.first!)
    let options = processArguments(commandName: url.lastPathComponent, Array(arguments.dropFirst()))

    switch options.mode {
    case .detect:
        do {
            let configuration = try createConfiguration(options: options)
            let analyzer = try Analyzer(configuration: configuration)
            let unusedSources = try analyzer.analyze()
            configuration.reporter.report(configuration, sources: unusedSources)
        } catch {
            log(error.localizedDescription, level: .error)
            return 1
        }
        return 0
    case .version:
        print("0.0.9")
        return 0
    }
}

private func createConfiguration(options: CommandLineOptions) throws -> Configuration {
    let processInfo = ProcessInfo()
    /// Find the index path, default is   ~Library/Developer/Xcode/DerivedData/<target>/Index/DataStore
    let buildRoot = try processInfo.environmentVariable(name: EnvironmentKeys.buildRoot)
    
    let indexStorePath: AbsolutePath
    if let indexStorePathString = options.indexStorePath {
        indexStorePath = AbsolutePath(indexStorePathString)
    } else {
        let buildRootPath = AbsolutePath(buildRoot)
        indexStorePath = buildRootPath.parentDirectory.parentDirectory.appending(component: "Index/DataStore")
    }
    
    guard let cwd = localFileSystem.currentWorkingDirectory else {
        throw PEError.fiendCurrentWorkingDirectoryFailed
    }
    let rootPath = AbsolutePath(options.path, relativeTo: cwd)
    let configuration = Configuration(projectPath: rootPath, indexStorePath: indexStorePath.asURL.path)
    
    return configuration
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
}

DispatchQueue.global().async {
    exit(main(CommandLine.arguments))
}

dispatchMain()



