import Foundation
import Path

/// Holds the complete set of configured values and defaults.
public struct Configuration {
    
    /// The  project path
    public let projectPath: Path
    
    /// The project index storePath path
    public let indexStorePath: String
    
    /// The project index database path
    public var indexDatabasePath: String = NSTemporaryDirectory() + "index_\(getpid())"
    
    public init(projectPath: Path, indexStorePath: String, indexDatabasePath: String? = nil) {
        self.projectPath = projectPath
        self.indexStorePath = indexStorePath
        self.indexDatabasePath = indexDatabasePath ?? self.indexDatabasePath
    }
}
