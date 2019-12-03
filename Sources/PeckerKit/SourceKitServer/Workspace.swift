import Foundation
import IndexStoreDB

public final class Workspace {
    
    static let libIndexStore = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libIndexStore.dylib"
        
    /// Build setup
    public let buildSettings: DatabaseBuildSystem

    /// The source code index, if available.
    public var index: IndexStoreDB? = nil
    
    /// The directory containing the original, unmodified project.
    public init(buildSettings: DatabaseBuildSystem) throws {
        self.buildSettings = buildSettings
        
        if let storePath = buildSettings.indexStorePath,
            let dbPath = buildSettings.indexStorePath {
            do {
                let lib = try IndexStoreLibrary(dylibPath: Workspace.libIndexStore)
                self.index = try IndexStoreDB(
                    storePath: URL(fileURLWithPath: storePath).path,
                    databasePath: dbPath,
                    library: lib,
                    listenToUnitEvents: false)
                log("opened IndexStoreDB at \(dbPath) with store path \(storePath)")
            } catch {
                log("failed to open IndexStoreDB: \(error.localizedDescription)", level: .error)
            }
        }
    }
}
