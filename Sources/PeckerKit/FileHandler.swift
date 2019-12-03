import Foundation
import Path

public func recursiveFiles(withExtensions exts: [String], at path: Path) throws -> [Path] {
    if path.isFile {
        if exts.contains(path.extension) {
            return [path]
        }
        return []
    } else if path.isDirectory {
        var files: [Path] = []
        for entry in try path.ls() {
            let list = try recursiveFiles(withExtensions: exts, at: entry.path)
            files.append(contentsOf: list)
        }
        return files
    }
    return []
}
