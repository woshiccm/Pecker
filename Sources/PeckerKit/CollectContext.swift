import Foundation
import SwiftSyntax

public struct CollectContext {
    
    let filePath: String
    
    /// The configuration for this run of the pipeline, provided by a configuration yml file.
    let configuration: Configuration
    
    /// An object that converts `AbsolutePosition` values to `SourceLocation` values.
    let sourceLocationConverter: SourceLocationConverter
    
    init(configuration: Configuration, filePath: String, sourceFileSyntax: SourceFileSyntax) {
        self.configuration = configuration
        self.filePath = filePath
        self.sourceLocationConverter = SourceLocationConverter(file: filePath, tree: sourceFileSyntax)
    }
}
