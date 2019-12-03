import Foundation
import Path

public func recursiveFiles(withExtensions exts: [String], at path: Path) -> [Path] {
    if path.isFile {
        if exts.contains(path.extension) {
            return [path]
        }
        return []
    } else if path.isDirectory {
        var files: [Path] = []
        do {
            for entry in try path.ls() {
                let list = recursiveFiles(withExtensions: exts, at: entry.path)
                files.append(contentsOf: list)
            }
        } catch {
            log("failed to path.ls: \(error.localizedDescription)", level: .warning)
        }
        return files
    }
    return []
}
