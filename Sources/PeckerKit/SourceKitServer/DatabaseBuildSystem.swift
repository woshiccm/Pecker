import Foundation

public struct DatabaseBuildSystem {
    
    /// The path to the raw index store data, if any.
    public var indexStorePath: String?
    
    /// The path to put the index database, if any.
    public var indexDatabasePath: String?
    
    public init(indexStorePath: String?, indexDatabasePath: String?) {
        self.indexStorePath = indexStorePath
        self.indexDatabasePath = indexDatabasePath
    }
}
