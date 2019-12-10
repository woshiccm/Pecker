import Foundation
import SwiftSyntax
import TSCBasic
public typealias FileSystem = TSCBasic.FileSystem

/// Collects source code in the path.
class SourceCollector {

    var sources: [SourceDetail] = []
    var sourceExtensions: [String: SourceDetail] = [:]
    private let configuration: Configuration
    private let targetPath: AbsolutePath
    private let excluded: [AbsolutePath]
    private let included: [AbsolutePath]
    private let blacklistFiles: [String]
    /// The file system to operate on.
    public let fs: FileSystem
    
    init(rootPath: AbsolutePath, configuration: Configuration) {
        self.targetPath = rootPath
        self.configuration = configuration
        self.fs = localFileSystem
        self.excluded = configuration.excluded
        self.included = configuration.included
        self.blacklistFiles = configuration.blacklistFiles
    }

    /// Populates the internal collections form the path source code
    /// Currently only supports Swift
    func collect() throws {
        let files = computeContents()
        for file in files {
            let syntax = try SyntaxParser.parse(file.asURL)
            let context = CollectContext(configuration: configuration,
                                         filePath: file.description,
                                         sourceFileSyntax: syntax)
            var pipeline = CollectPipeline(context: context)
            syntax.walk(&pipeline)
            sources += pipeline.sources
            sourceExtensions += pipeline.sourceExtensions
        }
    }
    
    /// Compute the contents of the files in a target.
    ///
    /// This avoids recursing into certain directories like exclude.
    func computeContents() -> [AbsolutePath] {
        var contents: [AbsolutePath] = []
        var queue: [AbsolutePath] = [targetPath]
        
        while let curr = queue.popLast() {
            
            // Ignore if this is an excluded path.
            if self.excluded.contains(curr) { continue }
            
            // Ignore if this is a blacklistFiles file.
            if blacklistFiles.contains(curr.basenameWithoutExt) { continue  }
            
            // Append and continue if the path doesn't have an extension or is not a directory.
            if curr.extension == "swift" && !fs.isDirectory(curr) {
                contents.append(curr)
                continue
            }
            
            do {
                // Add directory content to the queue.
                let dirContents = try fs.getDirectoryContents(curr).map{ curr.appending(component: $0) }
                queue += dirContents
            } catch {
                log(error.localizedDescription, level: .warning)
            }
        }
        
        return contents
    }
}
