import Foundation

public struct JSONReporter: Reporter {
    
    public func report(_ configuration: Configuration, sources: [SourceDetail]) {
        var entries = sources.map { $0.location.description }
        let count = entries.count
        entries.insert("count: \(count)", at: 0)
        do {
            try writeEntries(entries: entries, to: configuration.outputFile.asURL)
        } catch {
            log("Output json file failed: \(error.localizedDescription)", level: .warning)
        }
    }
}

private func writeEntries(entries: [String], to path: URL) throws {
    do {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(entries)
        try data.write(to: path, options: .atomic)
    }
}
