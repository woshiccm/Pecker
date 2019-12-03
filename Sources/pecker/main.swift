import Foundation
import SwiftSyntax
import PeckerKit
import Path
import TSCUtility
import TSCBasic
import IndexStoreDB

fileprivate func main(_ arguments: [String]) -> Int32 {
    let url = URL(fileURLWithPath: arguments.first!)
    let options = processArguments(commandName: url.lastPathComponent, Array(arguments.dropFirst()))
    switch options.mode {
    case .detect:
        do {
            let configuration = try createConfiguration(options: options)
            let detecter = try DeadCodeDetecter(configuration: configuration)
            let unusedSources = try detecter.detect()
            emit(sources: unusedSources)
            return 0
        } catch {
            return 1
        }
    case .version:
        print("0.0.1")
        return 0
    }
}

private func createConfiguration(options: CommandLineOptions) throws -> Configuration {
    let processInfo = ProcessInfo()
    let targetName = try processInfo.environmentVariable(name: EnvironmentKeys.target)
    let indexStorePath = try findIndexFile(targetName: targetName)
    guard let cwd = localFileSystem.currentWorkingDirectory else {
        throw PEError.fiendCurrentWorkingDirectoryFailed
    }
    
    let path = AbsolutePath(options.path, relativeTo: cwd)
    guard let projectPath = Path(path.asURL.path) else {
        throw PEError.findProjectFileFailed(message: "find project: \(targetName) Path failed")
    }
    
    let configuration = Configuration(projectPath: projectPath, indexStorePath: indexStorePath)
    
    return configuration
}

/// Find the index path, default is   ~Library/Developer/Xcode/DerivedData/<target>/Index/DataStore
private func findIndexFile(targetName: String) throws -> String {
    let url = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Developer/Xcode/DerivedData")
    var projectDerivedDataPath: Path?
    if let path = Path(url.path) {
        for entry in try path.ls() {
            if entry.path.basename().hasPrefix("\(targetName)-") {
                projectDerivedDataPath = entry.path
            }
        }
    }
    
    if let path = projectDerivedDataPath, let indexPath = Path(path.url.path+"/Index/DataStore")  {
        return indexPath.url.path
    }
    throw PEError.findIndexFailed(message: "find project: \(targetName) index under DerivedData failed")
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
}

enum ProcessError: Error {
    case missingValue(argument: String?)
}

enum PEError: Error {
    case findIndexFailed(message: String)
    case fiendCurrentWorkingDirectoryFailed
    case findProjectFileFailed(message: String)
}

exit(main(CommandLine.arguments))




