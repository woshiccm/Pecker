import Foundation
import Path
import SwiftSyntax

/// Collects source code in the path.
public class SourceCollector {
    
    let path: Path
    public var sources: [SourceDetail] = []
    public var sourceExtensions: [SourceDetail] = []
    
    init(path: Path) {
        self.path = path
    }

    /// Populates the internal collections form the path source code
    /// Currently only supports Swift
    func collect() throws {
        let files: [Path] = recursiveFiles(withExtensions: ["swift"], at: path)
        for file in files {
            let syntax = try SyntaxParser.parse(file.url)
            let sourceLocationConverter = SourceLocationConverter(file: file.description, tree: syntax)
            var visitor = SwiftVisitor(filePath: file.description, sourceLocationConverter: sourceLocationConverter)
            syntax.walk(&visitor)
            sources += visitor.sources
            sourceExtensions += visitor.sourceExtensions
        }
    }
}
