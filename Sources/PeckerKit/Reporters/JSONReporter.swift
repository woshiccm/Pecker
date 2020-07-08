import Foundation
import TSCUtility
import TSCBasic

public struct JSONReporter: Reporter {
    
    public func report(_ configuration: Configuration, sources: [SourceDetail]) {
        let entries = sources.map { JsonSymbol(symbol: $0.name, location: $0.location.description) }.sorted {
            $0.location < $1.location
        }
        do {
            try writeEntries(entries: entries, to: configuration.outputFile)
        } catch {
            log("Output json file failed: \(error.localizedDescription)", level: .warning)
        }
    }
}

struct JsonSymbol: Encodable, JSONSerializable {
    func toJSON() -> JSON {
        return .init(["symbol": symbol, "location": location])
    }
    
    let symbol: String
    let location: String
}

private func writeEntries(entries: [JsonSymbol], to path: AbsolutePath) throws {
    do {
        var jsonobject: [String: JSONSerializable] = [:]
        jsonobject["count"] = entries.count
        jsonobject["symbols"] = entries
        try localFileSystem.writeFileContents(path, bytes: JSON(jsonobject).toBytes(prettyPrint: true))
    }
}
