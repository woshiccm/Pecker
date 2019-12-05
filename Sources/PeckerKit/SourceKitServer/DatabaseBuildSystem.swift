import Foundation

struct DatabaseBuildSystem {
    
    /// The path to the raw index store data, if any.
    var indexStorePath: String?
    
    /// The path to put the index database, if any.
    var indexDatabasePath: String?
    
    init(indexStorePath: String?, indexDatabasePath: String?) {
        self.indexStorePath = indexStorePath
        self.indexDatabasePath = indexDatabasePath
    }
}
