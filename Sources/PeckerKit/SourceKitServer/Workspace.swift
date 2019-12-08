import Foundation
import IndexStoreDB

class Workspace {
    
    static let libIndexStore = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libIndexStore.dylib"
        
    /// Build setup
    let buildSettings: DatabaseBuildSystem

    /// The source code index, if available.
    var index: IndexStoreDB? = nil
    
    /// The directory containing the original, unmodified project.
    init(buildSettings: DatabaseBuildSystem) throws {
        self.buildSettings = buildSettings
        
        if let storePath = buildSettings.indexStorePath,
            let dbPath = buildSettings.indexDatabasePath {
            do {
                let lib = try IndexStoreLibrary(dylibPath: Workspace.libIndexStore)
                self.index = try IndexStoreDB(
                    storePath: URL(fileURLWithPath: storePath).path,
                    databasePath: NSTemporaryDirectory() + "index_\(getpid())",
                    library: lib,
                    listenToUnitEvents: false)
                log("opened IndexStoreDB at \(dbPath) with store path \(storePath)")
            } catch {
                log("failed to open IndexStoreDB: \(error.localizedDescription)", level: .error)
            }
        }
    }
}
