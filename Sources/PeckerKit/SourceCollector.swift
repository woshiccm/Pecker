import Foundation
import Path
import SwiftSyntax

/// Collects source code in the path.
class SourceCollector {

    var sources: [SourceDetail] = []
    var sourceExtensions: [SourceDetail] = []
    private let path: Path
    private let configuration: Configuration
    
    init(path: Path, configuration: Configuration) {
        self.path = path
        self.configuration = configuration
    }

    /// Populates the internal collections form the path source code
    /// Currently only supports Swift
    func collect() throws {
        let files: [Path] = recursiveFiles(withExtensions: ["swift"], at: path)
        for file in files {
            let syntax = try SyntaxParser.parse(file.url)
            let context = CollectContext(configuration: configuration,
                                         filePath: file.description,
                                         sourceFileSyntax: syntax)
            var pipeline = CollectPipeline(context: context)
            syntax.walk(&pipeline)
            sources += pipeline.sources
            sourceExtensions += pipeline.sourceExtensions
        }
    }
}
