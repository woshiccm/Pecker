import Foundation
import SwiftSyntax
import SwiftSyntaxParser
import TSCBasic

public typealias FileSystem = TSCBasic.FileSystem
typealias SafeSourceExtensions = ThreadSafe<[String: SourceDetail]>

/// Collects source code in the path.
class SourceCollector {

    let sourceExtensions = SafeSourceExtensions([:])
    private(set) var sources: [SourceDetail] = []
    private let configuration: Configuration
    private let targetPath: AbsolutePath
    private let excluded: Set<AbsolutePath>
    private let included: Set<AbsolutePath>
    private let excludedGroupName: Set<String>
    private let blacklistFiles: Set<String>
    /// The file system to operate on.
    private let fs: FileSystem
    
    init(rootPath: AbsolutePath, configuration: Configuration) {
        self.targetPath = rootPath
        self.configuration = configuration
        self.excluded = Set(configuration.excluded)
        self.included = Set(configuration.included)
        self.excludedGroupName = Set(configuration.excludedGroupName)
        self.blacklistFiles = Set(configuration.blacklistFiles)
        self.fs = localFileSystem
    }

    /// Populates the internal collections form the path source code
    /// Currently only supports Swift
    func collect() {
        let files = computeContents()
        let safeSources = ThreadSafe<[SourceDetail]>([])
        DispatchQueue.concurrentPerform(iterations: files.count) { index in
            let fileURL = files[index].asURL
            do {
                let syntax = try SyntaxParser.parse(fileURL)
                let context = CollectContext(configuration: configuration,
                                         filePath: files[index].description,
                                         sourceFileSyntax: syntax)
                let pipeline = SwiftSourceCollectVisitor(context: context)
                pipeline.walk(syntax)
                safeSources.atomically { $0 += pipeline.sources }
                sourceExtensions.atomically { $0 += pipeline.sourceExtensions }
            } catch {
                fputs("Error parsing \(fileURL) \(error)", stderr)
            }
        }
        sources = safeSources.value
    }

    /// Compute the contents of the files in a target.
    ///
    /// This avoids recursing into certain directories like exclude.
    private func computeContents() -> [AbsolutePath] {
        var contents: [AbsolutePath] = []
        var queue: [AbsolutePath] = [targetPath]

        while let curr = queue.popLast() {
            
            // Ignore if this is an excluded path.
            if self.excluded.contains(curr) { continue }
            
            // Ignore if this is an not included path.
            guard self.included.contains(where: { $0.contains(curr) || curr.contains($0) }) else {
                continue
            }
            
            // Append and continue if the path doesn't have an extension or is not a directory and is not in lacklistFiles.
            if curr.extension == "swift" && !blacklistFiles.contains(curr.basenameWithoutExt) {
                contents.append(curr)
                continue
            }
            
            // If not directory continue
            guard fs.isDirectory(curr) && !self.excludedGroupName.contains(curr.basenameWithoutExt) else {
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
